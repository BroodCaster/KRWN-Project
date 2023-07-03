# How to run project
1. Install all necessary packages
   ```shell
   npm i
   ```
2. Add your Private, Ethereum Api and Provider keys to .env_example file and rename it to .env
3. Compile all smart contracts
   ```shell
   npx hardhat compile
   ```
4. Deploy smart contract KRWN.sol
   ```shell
   npx hardhat run scripts/deploy.js --network <network-name>
   ```
5. Verify it
   ```shell
   npx hardhat verify --network <network-name> <address> <constructor args>
   ```

# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```
