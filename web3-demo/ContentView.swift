//
//  ContentView.swift
//  web3-demo
//
//  Created by Byurhan Beyzat on 19.04.22.
//

import SwiftUI
import web3swift

struct ContentView: View {
    let web3 = Web3Provider()
    
    var body: some View {
        Button("Create Identity") {
            print("Creating identity....")
            web3.createAccount(password: "123123")
            print(web3.wallet ?? "No wallet")
            
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 12.0)
        .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
        .cornerRadius(6)
        
        Button("Import Identity") {
            print("Import identity....")
            web3.importAccount(privateKey: "53f5adbf9dfd27da65d293d2681906085dab643e6cda3e3d4843e9bdd0e93d2d", password: "123123")
            print(web3.wallet ?? "No wallet")
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
            let contractAddress = EthereumAddress("0x308d002805D50AdD08440239fB9118b87cD61cef")!
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
        
        Button("Verify Terms") {
            print("Verify Terms....")
            let contractAddress = EthereumAddress("0x308d002805D50AdD08440239fB9118b87cD61cef")!
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
