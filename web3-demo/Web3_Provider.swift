//
//  Web3_Provider.swift
//  web3-demo
//
//  Created by Byurhan Beyzat on 19.04.22.
//

import Foundation
import web3swift

struct Wallet {
    let address: String
    let data: Data
    let name: String
    let isHD: Bool
}

class Web3Provider {
    public var client: web3
    public var wallet: Wallet!
    private let keystoreManager = try! EthereumKeystoreV3(password: "storePass")!

    init() {
        let endpoint = "http://127.0.0.1:7545"
        client = web3(provider: Web3HttpProvider(URL(string: endpoint)!)!)
    }
    
    func createAccount(password: String, name: String = "Wallet") {
        let keystore = try! EthereumKeystoreV3(password: password)!
        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
        let address = keystore.addresses!.first!.address
        wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
    }

    func importAccount(privateKey: String, password: String, name: String = "Wallet") {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)!
        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
        let address = keystore.addresses!.first!.address
        wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
    }
}
