const HDWalletProvider = require('@truffle/hdwallet-provider');

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
  networks: {
    development: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 7545,            // Standard Ethereum port (default: none)
     network_id: "5777",       // Any network (default: none)
    },
    goerli: {
      provider: () => new HDWalletProvider(mnemonic, `https://goerli.infura.io/v3/YOUR-PROJECT-ID`), // Here you need to replac "YOUR-PROJECT-ID" to your Infura ID
      network_id: 5,       
      gas: 5500000,          
      timeoutBlocks: 200,  
      skipDryRun: true    
    },
    mainnet: {
    provider: () => new HDWalletProvider(mnemonic, `https://mainnet.infura.io/v3/YOUR-PROJECT-ID`), // Here you need to replac "YOUR-PROJECT-ID" to your Infura ID
    network_id: 1,          
    timeoutBlocks: 200,  
    skipDryRun: true    
    },
  },
  // Configure your compilers
 
  compilers: {
      solc: {
        version: "^0.8.0",    // Fetch exact version from solc-bin (default: truffle's version)
        docker: false,        // Use "0.5.1" you've installed locally with docker (default: false)
        settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200
        },
        }
      }
  },
  plugins: ['truffle-plugin-verify'],
  api_keys: {
    etherscan: 'FE4B7IDD87JA85Q3MYW73WRFUWD2NYT21C'
  }
};

