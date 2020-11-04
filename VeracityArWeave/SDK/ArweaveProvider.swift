//
//  ArweaveProvider.swift
//  VeracityArWeave
//
//  Created by Chu Anh Minh on 10/30/20.
//

import Foundation

public enum ArweaveError: Error {
    case uploadFailed
    case alreadyUploading
    case generateFailed
}

public struct UploadParams: Codable {
    let wallet: Wallet
    let fileName: String
}

public struct UploadResponse: Codable {
    let progress: Int
    let fileName: String
    let transactionId: String
    let failed: Bool
    let completed: Bool
}

private typealias UploadCompletion = (Result<URL, ArweaveError>) -> Void
private typealias WalletCompletion = (Result<Wallet, ArweaveError>) -> Void
private typealias ProgressBlock = (Int) -> Void

public final class ArweaveProvider: NSObject {
    static let shared = ArweaveProvider()

    var inputStream: InputStream!
    var outputStream: OutputStream!

    //(fileName:)
    private var uploadBlocks: [String: UploadCompletion] = [:]
    private var progressBlocks: [String: ProgressBlock] = [:]
    private var walletBlock: WalletCompletion?

    private override init() {
        super.init()
        startNode()
    }

    deinit {
        stopSession()
    }

    private func setupSocket() {
        print("setting up ")
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           "127.0.0.1" as CFString,
                                           6969,
                                           &readStream,
                                           &writeStream)

        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()

        inputStream.delegate = self

        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)

        inputStream.open()
        outputStream.open()
    }

    private func stopSession() {
        inputStream.close()
        outputStream.close()
    }

    private func startNode() {
        DispatchQueue.global().async {
            let path = Bundle.main.path(forResource: "JS/index", ofType: "js")
            NodeRunner.startEngine(withArguments: ["node", path!])
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.setupSocket()
        }
    }

    public func generateWallet(result: @escaping (Result<Wallet, ArweaveError>) -> Void) {
        if walletBlock != nil {
            result(.failure(.generateFailed))
            return
        }

        DispatchQueue.global().async {
            let upData = "generateWallet".data(using: .utf8)!

            upData.withUnsafeBytes { [weak self] in
                guard let self = self else { return }
                guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                    result(.failure(.generateFailed))
                    return
                }

                self.walletBlock = result
                self.outputStream.write(pointer, maxLength: upData.count)
            }
        }
    }

    public func uploadData(
        data: Data,
        fileName: String,
        wallet: Wallet,
        progress: @escaping ((Int) -> Void),
        result: @escaping (Result<URL, ArweaveError>) -> Void) {
        DispatchQueue.global().async {
            guard !fileName.isEmpty else {
                result(.failure(.uploadFailed))
                return
            }

            guard self.uploadBlocks[fileName] == nil else {
                result(.failure(.alreadyUploading))
                return
            }

            do {
                try self.saveTmpFile(fileName: fileName, data: data)

                let upData = try JSONEncoder().encode(UploadParams(wallet: wallet, fileName: fileName))

                upData.withUnsafeBytes { [weak self] in
                    guard let self = self else { return }
                    guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                        result(.failure(.uploadFailed))
                        try? self.removeTmpFile(fileName: fileName)
                        return
                    }

                    self.uploadBlocks[fileName] = result
                    self.progressBlocks[fileName] = progress

                    self.outputStream.write(pointer, maxLength: upData.count)
                }
            } catch {
                try? self.removeTmpFile(fileName: fileName)
                print(error)
                result(.failure(.uploadFailed))
            }
        }
    }

    private func saveTmpFile(fileName: String, data: Data) throws {
        let tempDirectory = NSTemporaryDirectory().appending("files")

        if !FileManager.default.fileExists(atPath: tempDirectory) {
            try FileManager.default.createDirectory(atPath: tempDirectory,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        }

        let url = URL(fileURLWithPath: tempDirectory.appending("/\(fileName)"))
        try data.write(to: url)
    }

    private func removeTmpFile(fileName: String) throws {
        let tempDirectory = NSTemporaryDirectory().appending("files")
        print(tempDirectory)

        if !FileManager.default.fileExists(atPath: tempDirectory) {
            try FileManager.default.createDirectory(atPath: tempDirectory,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        }

        let url = URL(fileURLWithPath: tempDirectory.appending("/\(fileName)"))

        try FileManager.default.removeItem(at: url)
    }
}

extension ArweaveProvider: StreamDelegate {
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            print("new message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            print("new message received")
            stopSession()
        case .errorOccurred:
            print("error occurred")
        case .hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
        }
    }

    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: 4096)
            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }

            let data = Data(bytes: buffer, count: numberOfBytesRead)
            if let progress = try? JSONDecoder().decode(UploadResponse.self, from: data) {
                self.processUpload(progress: progress)
                return
            }

            if let wallet = try? JSONDecoder().decode(Wallet.self, from: data) {
                walletBlock?(.success(wallet))
                walletBlock = nil
            }
        }
    }

    private func processUpload(progress: UploadResponse) {
        if progress.failed {
            uploadBlocks[progress.fileName]?(.failure(.uploadFailed))
            uploadBlocks[progress.fileName] = nil
            progressBlocks[progress.fileName] = nil
            try? removeTmpFile(fileName: progress.fileName)
            return
        }

        progressBlocks[progress.fileName]?(progress.progress)

        if progress.completed {
            let url = "https://arweave.net/\(progress.transactionId)/\(progress.fileName)"

            uploadBlocks[progress.fileName]?(.success(URL(string: url)!))

            uploadBlocks[progress.fileName] = nil
            progressBlocks[progress.fileName] = nil

            try? removeTmpFile(fileName: progress.fileName)
        }
    }
}
