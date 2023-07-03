require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */


module.exports = {
  defaultNetwork: "mainnet",
  networks: {
    hardhat: {
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${process.env.API_KEY}`,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    },
    mainnet: {
      url: `https://polygon-mainnet.infura.io/v3/${process.env.API_KEY}`,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    }
  },
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
}