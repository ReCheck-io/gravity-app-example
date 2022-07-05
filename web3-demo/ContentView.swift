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
    let web3p = Web3Provider()
    
    var accountPassword = "123123123"
    var privateKeyForImportWallet = "b142d54571d9f9775659564d284208a828e5d211409bb18e053f045c0176f8a6"
    var mnemonicsForImportWallet = "fluid kind bird ice wing ribbon era common scissors stock chat estate"
    
    @State var address: String = "Wallet: N/A"
    
    var body: some View {
        VStack(alignment: .center) {
            Text(address)
                .multilineTextAlignment(.center)
                .padding(16.0)

            
            Button("Sign Terms (Gassless)") {
                print("Sign Terms (Gassless)....")
                
                web3p.createAccount(password: accountPassword)
                
                let geip712 = GEIP712()
                
                try? geip712.signTerms(
                    keystore: web3p.wallet.keystore!,
                    keyStorePassword: accountPassword,
                    termsHash: "0x4f18e5cf5b77b13fb6c80122b3cde9697e7b0a35aef062ed33b683fbf072489b",
                    termsVersion: "0x4f18e5cf5b77b13fb6c80122b3cde9697e7b0a35aef062ed33b683fbf072489b")
            }
            .padding(.horizontal, 12.0)
            .padding(.vertical, 8.0)
            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
            .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
            
            
            
            Button("Import Identity w/ PrivateKey") {
                print("Import identity....")
                web3p.importAccountWith(privateKey: privateKeyForImportWallet, password: accountPassword)
                print(web3p.wallet ?? "No wallet")
                address = "Wallet: " + web3p.wallet.address
            }
            .padding(.horizontal, 12.0)
            .padding(.vertical, 8.0)
            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
            .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
            
            Button("Import Identity w/ Mnemonic") {
                print("Import identity with mnemonic....")
                web3p.importAccountWith(mnemonics: mnemonicsForImportWallet, password: accountPassword)
                print(web3p.wallet ?? "No wallet")
                address = "Wallet: " + web3p.wallet.address
            }
            .padding(.horizontal, 12.0)
            .padding(.vertical, 8.0)
            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
            .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
            
            Button("Create Identity") {
                print("Creating identity....")
                web3p.createAccount(password: accountPassword)
                print(web3p.wallet ?? "No wallet")
                address = "Wallet: " + web3p.wallet.address
                
//                do {
//                    let sourceData = "hello world".data(using: .utf8)!
//                    let password = "foo123123bar"
//                    let salt = AES256.randomSalt()
//                    let iv = AES256.randomIv()
//                    let key = try AES256.createKey(password: password.data(using: .utf8)!, salt: salt)
//                    let aes = try AES256(key: key, iv: iv)
//                    let encrypted = try aes.encrypt(sourceData)
//                    let decrypted = try aes.decrypt(encrypted)
//
//                    print("Encrypted: \(encrypted.hexString)")
//                    print("Decrypted: \(decrypted.hexString)")
//                    print("Password: \(password)")
//                    print("Key: \(key.hexString)")
//                    print("IV: \(iv.hexString)")
//                    print("Salt: \(salt.hexString)")
//                    print(" ")
//
//                } catch {
//                    print("Failed")
//                    print(error)
//                }
            }
            .padding(.horizontal, 12.0)
            .padding(.vertical, 8.0)
            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
            .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
            
            Button("Get Balance") {
                print("Get Balance....")
//                let walletAddress = EthereumAddress(web3p.wallet.address)!
//                let balanceResult = try! web3p.client.eth.getBalance(address: walletAddress)
//                let balanceString = web3p.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
//
//                print(balanceString)
            }
            .padding(.horizontal, 12.0)
            .padding(.vertical, 8.0)
            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
            .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
            
            Button("Sign Raw Tx") {
                print("Sign Raw Tx....")
               
                let message = "Hello World"
                let walletAddress = EthereumAddress(web3p.wallet.address)!
                let signature = try! Web3Signer.signPersonalMessage(
                    message.data(using: .utf8)!,
                    keystore: web3p.wallet.keystore!,
                    account: walletAddress,
                    password: accountPassword)!
                
//              let signature = try! web3p.client.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: walletAddress)
                print(" ", signature.toHexString())
                let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: signature)!
                print("V = " + String(unmarshalledSignature.v))
                print("R = " + Data(unmarshalledSignature.r).toHexString())
                print("S = " + Data(unmarshalledSignature.s).toHexString())
                print("Personal hash = " + Web3.Utils.hashPersonalMessage(message.data(using: .utf8)!)!.toHexString())
                let signer = Web3Utils.personalECRecover(message.data(using: .utf8)!, signature: signature)
//              let signer = try web3p.client.personal.ecrecover(personalMessage: message.data(using: .utf8)!, signature: signature)
                print(signer?.address as Any)
            }
            .padding(.horizontal, 12.0)
            .padding(.vertical, 8.0)
            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
            .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
            
            Button("Sign Terms") {
                print("Sign Terms....")
//                let walletAddress = EthereumAddress(web3p.wallet.address)!
//
//                guard let url = Bundle.main.url(forResource: "ContractABI", withExtension: "json") else {
//                    print("File not found")
//                    return
//                }
//
//                let contractABI = try! String(contentsOf: url)
//                let contract = web3p.client.contract(contractABI, at: web3p.contractAddress, abiVersion: 2)!
//                let parameters = [
//                    "0x4f18e5cf5b77b13fb6c80122b3cde9697e7b0a35aef062ed33b683fbf072489b",
//                    "0x4f18e5cf5b77b13fb6c80122b3cde9697e7b0a35aef062ed33b683fbf072489b"]
//
//                var options = TransactionOptions.defaultOptions
//                options.value = Web3.Utils.parseToBigUInt("0.0", units: .eth)
//                options.from = walletAddress
//                options.gasPrice = .automatic
//                options.gasLimit = .automatic
//
//                let tx = contract.write("signTerms", parameters: parameters as [AnyObject], extraData: Data() as Data, transactionOptions: options)!
//
//                print("Tx object", tx.transaction)
//
//                let res = try? tx.send()
//
//                print(res as Any)
                
            }
            .padding(.horizontal, 12.0)
            .padding(.vertical, 8.0)
            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
            .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
            
            Button("Verify Signature") {
                print("Verify Signature....")
//                let walletAddress = EthereumAddress(web3p.wallet.address)!
//
//                guard let url = Bundle.main.url(forResource: "ContractABI", withExtension: "json") else {
//                    print("File not found")
//                    return
//                }
//
//                let contractABI = try! String(contentsOf: url)
//                let contract = web3p.client.contract(contractABI, at: web3p.contractAddress, abiVersion: 2)!
//
//                let parameters = [
//                    walletAddress.address,
//                    "0x4f18e5cf5b77b13fb6c80122b3cde9697e7b0a35aef062ed33b683fbf072489b",
//                    "0x4f18e5cf5b77b13fb6c80122b3cde9697e7b0a35aef062ed33b683fbf072489b"]
//
//                var options = TransactionOptions.defaultOptions
//                options.from = walletAddress
//                options.gasPrice = .automatic
//                options.gasLimit = .automatic
//
//                let tx = contract.read("validateSignature", parameters: parameters as [AnyObject], extraData: Data() as Data,transactionOptions: options)!
//
//                let res = try? tx.call()
//
//                print(res as Any)
                
            }
            .padding(.horizontal, 12.0)
            .padding(.vertical, 8.0)
            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
            .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

