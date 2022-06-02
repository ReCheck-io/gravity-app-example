# gravity-web3-example


## Setup Ganache
- Install: https://trufflesuite.com/ganache/
- Start app and click "Quickstart (Ethereum)" button - This will start blochain on the address: `http://127.0.0.1:7545`

## Setup Contracts locally
- Get/clone smart contracts
- Install Truffle cli tool globally (to build and deploy smart contracts to the blockchain) - `npm install -g truffle`

- Open smart contracts folder in terminal and execute the following commands:
```
## Compile contracts
$ truffle compile

## Test contracts
$ truffle test

## Deploy contracts (this by default will deploy contracts to http://127.0.0.1:7545)
$ truffle migrate
```

## Changes needed for the example code to work
- Update blockchain endpoint `http://127.0.0.1:7545` (only if it's different from the default one) - `Web3_Provider.swift` file `endpoint` variable
- Update smart contract address - `Web3_Provider.swift` file `contractAddress` variable
- In order to test Sign Terms or Verify Signature you should import wallets with balance - Variables are in `ContentView.swift` file
  - There is two way to import wallet with mnemonics (update `mnemonicsForImportWallet` variable) or with private key (update `privateKeyForImportWallet` variable) this will import wallets from Ganache

- Wallets/Addresses created in the app won't have balance so they won't be able to do any operation
