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
    
    // Update with blockchain address
    private var endpoint = "http://127.0.0.1:7545"
    
    // Update after deploying contracts
    public var contractAddress = EthereumAddress("0xdBc9205f1fF6Fa1B543034a600a44ae96D56589A")!

    init() {
        client = web3(provider: Web3HttpProvider(URL(string: endpoint)!)!)
    }
    
    func createAccount(password: String, name: String = "Wallet") {
        // Create mnemonics
        let bitsOfEntropy: Int = 128 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
        let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!
    
        let keystore = try! BIP32Keystore(mnemonics: mnemonics, password: password, mnemonicsPassword: "", language: .english)!
        
        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
        let address = keystore.addresses!.first!.address
        wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
        
        let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: keystore.addresses!.first!)
        
        print("Mnemonics :-> ", mnemonics.description)
        print("Address :-> ", address as Any)
        print("Address :-> ", keystore.addresses as Any)
        print("Private Key :-> ", privateKey?.hexString as Any)
    }

    func importAccountWith(privateKey: String = "", mnemonics: String = "", password: String, name: String = "Wallet") {
        if (privateKey != "" && mnemonics == "") {
            let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
            let dataKey = Data.fromHex(formattedKey)!
            let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)!
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!.address
            wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
            
            let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: keystore.addresses!.first!)
            
            print("Address :-> ", address as Any)
            print("Address :-> ", keystore.addresses as Any)
            print("Private Key :-> ", privateKey?.hexString as Any)
        } else if (privateKey == "" && mnemonics != ""){
            let keystore = try! BIP32Keystore(mnemonics: mnemonics , prefixPath: "m/44'/77777'/0'/0")!
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!.address
            wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
            
            let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: keystore.addresses!.first!)
            
            print("Mnemonics :-> ", mnemonics.description)
            print("Address :-> ", address as Any)
            print("Address :-> ", keystore.addresses as Any)
            print("Private Key :-> ", privateKey?.hexString as Any)
        }
    }
}
