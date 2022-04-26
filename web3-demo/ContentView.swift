//
//  ContentView.swift
//  web3-demo
//
//  Created by Byurhan Beyzat on 19.04.22.
//

import SwiftUI
import web3swift

extension Data {
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

struct ContentView: View {
    let web3 = Web3Provider()
    @State var address: String = "No Wallet"
    
    var body: some View {
        
        Text(address)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16.0)

        
        Button("Create Identity") {
            
            print("Creating identity....")
            web3.createAccount(password: "123123")
            print(web3.wallet ?? "No wallet")
            address = "Wallet: " + web3.wallet.address
            
            do {
                let sourceData = "hello world".data(using: .utf8)!
                let password = "foo123123bar"
                let salt = AES256.randomSalt()
                let iv = AES256.randomIv()
                let key = try AES256.createKey(password: password.data(using: .utf8)!, salt: salt)
                let aes = try AES256(key: key, iv: iv)
                let encrypted = try aes.encrypt(sourceData)
                let decrypted = try aes.decrypt(encrypted)
                
                print("Encrypted: \(encrypted.hexString)")
                print("Decrypted: \(decrypted.hexString)")
                print("Password: \(password)")
                print("Key: \(key.hexString)")
                print("IV: \(iv.hexString)")
                print("Salt: \(salt.hexString)")
                print(" ")
                
            } catch {
                print("Failed")
                print(error)
            }
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 12.0)
        .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
        .cornerRadius(6)
        
        Button("Import Identity") {
            print("Import identity....")
            web3.importAccountWith(privateKey: "02fd8114a074b128d1b06436870308a0f0b6b9678da6635a92d3799f49bf9696", password: "123123")
            print(web3.wallet ?? "No wallet")
            address = "Wallet: " + web3.wallet.address
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 12.0)
        .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
        .cornerRadius(6)
        
        Button("Import Identity") {
            print("Import identity with mnemonic....")
            web3.importAccountWith(mnemonics: "fluid kind bird ice wing ribbon era common scissors stock chat estate", password: "123123")
            print(web3.wallet ?? "No wallet")
            address = "Wallet: " + web3.wallet.address
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 12.0)
        .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
        .cornerRadius(6)
        
        
        
        Button("Get Balance") {
            print("Get Balance....")
            let walletAddress = EthereumAddress(web3.wallet.address)!
            let balanceResult = try! web3.client.eth.getBalance(address: walletAddress)
            let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
            
            print(balanceString)
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 12.0)
        .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
        .cornerRadius(6)
        
        Button("Sign Terms") {
            print("Sign Terms....")
            let contractAddress = EthereumAddress("0x469B116498b9848566d14D7Bb0Ab2c1B8a3166C1")!
            let walletAddress = EthereumAddress(web3.wallet.address)!
            
            guard let url = Bundle.main.url(forResource: "ContractABI", withExtension: "json") else {
                print("File not found")
                return
            }
            
            let contractABI = try! String(contentsOf: url)
            
            let contract = web3.client.contract(contractABI, at: contractAddress, abiVersion: 2)!
            let parameters = [
                "0x4f18e5cf5b77b13fb6c80122b3cde9697e7b0a35aef062ed33b683fbf072489b",
                "0x4f18e5cf5b77b13fb6c80122b3cde9697e7b0a35aef062ed33b683fbf072489b"]
            
            var options = TransactionOptions.defaultOptions
            options.value = Web3.Utils.parseToBigUInt("0.0", units: .eth)
            options.from = walletAddress
            options.gasPrice = .automatic
            options.gasLimit = .automatic
            
            let tx = contract.write("signTerms", parameters: parameters as [AnyObject], extraData: Data() as Data, transactionOptions: options)!
            
            let res = try? tx.send()
            
            print(res)
            
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 12.0)
        .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
        .cornerRadius(6)
        
        Button("Verify Signature") {
            print("Verify Signature....")
            let contractAddress = EthereumAddress("0x469B116498b9848566d14D7Bb0Ab2c1B8a3166C1")!
            let walletAddress = EthereumAddress(web3.wallet.address)!
            
            guard let url = Bundle.main.url(forResource: "ContractABI", withExtension: "json") else {
                print("File not found")
                return
            }
            
            let contractABI = try! String(contentsOf: url)
            
            let contract = web3.client.contract(contractABI, at: contractAddress, abiVersion: 2)!
            let parameters = [
                walletAddress.address,
                "0x4f18e5cf5b77b13fb6c80122b3cde9697e7b0a35aef062ed33b683fbf072489b",
                "0x4f18e5cf5b77b13fb6c80122b3cde9697e7b0a35aef062ed33b683fbf072489b"]
            
            var options = TransactionOptions.defaultOptions
            options.from = walletAddress
            options.gasPrice = .automatic
            options.gasLimit = .automatic
            
            let tx = contract.read("validateSignature", parameters: parameters as [AnyObject], extraData: Data() as Data,transactionOptions: options)!
            
            let res = try? tx.call()
            
            print(res)
            
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 12.0)
        .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
        .cornerRadius(6)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
