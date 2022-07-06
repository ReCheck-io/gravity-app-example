//
//  Web3_Provider.swift
//  web3-demo
//
//  Created by Byurhan Beyzat on 19.04.22.
//

import Foundation
import web3swift

struct RelayerPayload: Codable {
    let tosHash: String
    let from: EthereumAddress
    let signature: String
}

struct Wallet {
    let address: String
    let data: Data
    let name: String
    let isHD: Bool
    let keystore: BIP32Keystore?
}

class Web3Provider {
    public var wallet: Wallet!
    private let relayUrl: String = "https://gravity-relay.recheck.io"
    
    func createAccount(password: String, name: String = "Wallet") {
        // Create mnemonics
        let bitsOfEntropy: Int = 128 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
        let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!
    
        let keystore = try! BIP32Keystore(mnemonics: mnemonics, password: password, language: .english)!
        
        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
        let address = keystore.addresses!.first!.address
        wallet = Wallet(address: address, data: keyData, name: name, isHD: false, keystore: keystore)
        
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
            wallet = Wallet(address: address, data: keyData, name: name, isHD: false, keystore: nil)
            
            let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: keystore.addresses!.first!)
            
            print("Address :-> ", address as Any)
            print("Address :-> ", keystore.addresses as Any)
            print("Private Key :-> ", privateKey?.hexString as Any)
        } else if (privateKey == "" && mnemonics != ""){
            let keystore = try! BIP32Keystore(mnemonics: mnemonics, password: password, prefixPath: "m/44'/77777'/0'/0")!
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!.address
            wallet = Wallet(address: address, data: keyData, name: name, isHD: false, keystore: keystore)
            
            let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: keystore.addresses!.first!)
            
            print("Mnemonics :-> ", mnemonics.description)
            print("Address :-> ", address as Any)
            print("Address :-> ", keystore.addresses as Any)
            print("Private Key :-> ", privateKey?.hexString as Any)
        }
    }
    
    func signTerms(keystore: BIP32Keystore, keyStorePassword: String, tosHash: String) throws {
        let userAddress = keystore.addresses?[0]
        
        let signature = try Web3Signer.signPersonalMessage(
            Data(hex: tosHash),
            keystore: keystore,
            account: userAddress!,
            password: keyStorePassword
        )
        
        let hashSignature = "0x" + (signature?.toHexString())!
        print("hashSignature:", hashSignature)
        
        let signee = Web3Utils.personalECRecover(Data(hex: tosHash), signature: signature!)
        print("Recovered address:", signee as Any);
        
        let payload = RelayerPayload(tosHash: tosHash, from: userAddress!, signature: hashSignature)

        submitRelayRequest(object: payload)
        
        func submitRelayRequest(object: RelayerPayload) {
            do {
                let jsonData = try JSONEncoder().encode(object)
                print(String(data: jsonData, encoding: .utf8) as Any)
                let url = URL(string: relayUrl + "/relay")!
                var request = URLRequest(url: url)
                
                request.httpBody = jsonData
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard
                        let data = data,                              // is there data
                        let response = response as? HTTPURLResponse,  // is there HTTP response
                        200 ..< 300 ~= response.statusCode,           // is statusCode 2XX
                        error == nil                                  // was there no error
                    else {
                        return
                    }
                    
                    let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                    print("Tx response: ", responseObject as Any)
                }

                task.resume()
            } catch {
                print(error)
            }
        }
    }
    
    func verifyTermsSignature(keystore: BIP32Keystore, tosHash: String) throws {
        let userAddress = keystore.addresses?[0]
        
        let url = relayUrl + "/verifySignature"
        var components = URLComponents(string: url)!
        components.queryItems = [
            URLQueryItem(name: "tosHash", value: tosHash),
            URLQueryItem(name: "account", value: userAddress?.address)
        ]
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")

        var request = URLRequest(url: components.url!)

        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,                              // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                200 ..< 300 ~= response.statusCode,           // is statusCode 2XX
                error == nil                                  // was there no error
            else {
                return
            }
            
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            print("Verify Signature Response: ", responseObject as Any)
        }

        task.resume()
    }
}
