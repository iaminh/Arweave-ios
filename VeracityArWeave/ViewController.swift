//
//  ViewController.swift
//  VeracityArWeave
//
//  Created by Chu Anh Minh on 10/23/20.
//

import UIKit

class ViewController: UIViewController {
    private let provider = ArweaveProvider.shared

    @IBAction func buttonTap(_ sender: Any) {

        generateWallet()
        // upload()
    }

    private func generateWallet() {
        let result: (Result<Wallet, ArweaveError>) -> Void = { result in
            switch result {
            case .success(let wallet):
                print("generate wallet succeded \(wallet)")
            case .failure(_):
                print("failed hard")
            }
        }

        self.provider.generateWallet(result: result)
    }

    private func upload() {
        let progress: (Int) -> Void = { print("Uploading progress... \($0) %") }
        let result: (Result<URL, ArweaveError>) -> Void = { result in
            switch result {
            case .success(let url):
                print(url)
            case .failure(_):
                print("failed hard")
            }
        }

        DispatchQueue.global().async {
            self.provider.uploadData(data: UIImage(named: "airbag")!.pngData()!,
                                fileName: "jesus.png",
                                wallet: Wallet.tmp(),
                                progress: progress,
                                result: result)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}



