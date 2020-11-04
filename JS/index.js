const Arweave = require("arweave");
const arweave = Arweave.init({
  host: "arweave.net", // Hostname or IP address for a Arweave host
  port: 443, // Port
  protocol: "https", // Network protocol http or https
  timeout: 20000, // Network request timeouts in milliseconds
  logging: false, // Enable network request logging
});

var net = require("net");

var HOST = "127.0.0.1";
var PORT = 6969;

// Create a server instance, and chain the listen function to it
// The function passed to net.createServer() becomes the event handler for the 'connection' event
// The sock object the callback function receives UNIQUE for each connection
net
  .createServer(function (sock) {
    // We have a connection - a socket object is assigned to the connection automatically
    console.log("CONNECTED: " + sock.remoteAddress + ":" + sock.remotePort);
    // Add a 'data' event handler to this instance of socket
    sock.on("data", function (data) {
      console.log("uploading 1 2 3 4 5");

      if (data.toString() == "generateWallet") {
        generateWallet((wallet) => {
          sock.write(JSON.stringify(wallet));
        });
        return;
      }

      let json = JSON.parse(data);

      uploadData(
        json,
        (progress) => {
          sock.write(
            JSON.stringify({
              progress: progress.progress,
              fileName: json.fileName,
              transactionId: progress.transactionId,
              failed: false,
              completed: false,
            })
          );
        },
        (completed) => {
          sock.write(
            JSON.stringify({
              progress: 100,
              fileName: json.fileName,
              transactionId: completed.transactionId,
              failed: false,
              completed: true,
            })
          );
        },
        (error) => {
          sock.write(
            JSON.stringify({
              progress: 0,
              fileName: json.fileName,
              transactionId: "",
              failed: true,
              completed: false,
            })
          );
        }
      );
    });

    // Add a 'close' event handler to this instance of socket
    sock.on("close", function (data) {
      console.log("CLOSED: " + sock.remoteAddress + " " + sock.remotePort);
    });
  })
  .listen(PORT, HOST);

console.log("Server listening on " + HOST + ":" + PORT);

async function generateWallet(res) {
  const key = await arweave.wallets.generate();
  const address = await arweave.wallets.jwkToAddress(key);

  const wallet = { address: address, key: key };
  res(wallet);
}

async function uploadData(body, onProgress, onCompleted, onError) {
  console.log("uploading data");
  const fs = require("fs");
  const os = require("os");
  const tmpFolder = os.tmpdir() + "/files";
  const filename = body.fileName;
  const key = body.wallet.key;

  console.log(tmpFolder);
  console.log(filename);
  console.log(key);

  let data = fs.readFileSync(`${tmpFolder}/${filename}`);

  try {
    let transaction = await arweave.createTransaction({ data: data }, key);
    await arweave.transactions.sign(transaction, key);
    let uploader = await arweave.transactions.getUploader(transaction);

    console.log(transaction);

    while (!uploader.isComplete) {
      await uploader.uploadChunk();
      onProgress({
        progress: uploader.pctComplete,
        transactionId: transaction.id,
      });
    }

    if (uploader.isComplete) {
      onCompleted({ transactionId: transaction.id });
    }
  } catch (err) {
    console.log(err);
    onError({ transactionId: transaction.id });
  }
}
