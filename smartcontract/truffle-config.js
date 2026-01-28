const HDWalletProvider = require("@truffle/hdwallet-provider");
require("dotenv").config();

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
    },
    polygonAmoy: {
      provider: () =>
        new HDWalletProvider(
          process.env.PRIVATE_KEY,
          `https://polygon-amoy.infura.io/v3/${process.env.INFURA_API_KEY}`
        ),
      network_id: 80002,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    polygonMainnet: {
      provider: () =>
        new HDWalletProvider(
          process.env.PRIVATE_KEY,
          `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`
        ),
      network_id: 137,
      gasPrice: 10000000000,
    },
  },
  compilers: {
    solc: {
      version: "0.8.20",
      settings: {
        optimizer: { enabled: true, runs: 200 },
      },
    },
  },
};