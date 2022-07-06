//
//  EIP712.swift
//  web3-demo
//
//  Created by Emil Stoyanov on 29.06.22.
//

import Foundation
import web3swift

struct RelayerPayload: Codable {
    let tosHash: String
    let from: EthereumAddress
    let signature: String
}


class GEIP712 {
    
//    this combo works
//    let relayContract: String = "0xaC4c847899f7A38b166DCcb83171eF4c19FD4c9C"
//    let tosContract: String = "0x3F06bAAdA68bB997daB03d91DBD0B73e196c5A4d"
    
//    let tosContract: String = "0x5DCC06c74BCaBb840B08F05399A44AEc3ED1bdD4"
//    let relayContract: String = "0xaC4c847899f7A38b166DCcb83171eF4c19FD4c9C"
    
//    let tosContract: String = "0x3F06bAAdA68bB997daB03d91DBD0B73e196c5A4d"
//    let relayContract: String = "0x3F06bAAdA68bB997daB03d91DBD0B73e196c5A4d"
    let relayUrl: String = "https://gravity-relay.recheck.io"
    
    

    func signTerms(keystore: BIP32Keystore, keyStorePassword: String, tosHash: String) throws {
        let userAddress = keystore.addresses?[0]

        let signature = try Web3Signer.signPersonalMessage(
            tosHash.data(using: .utf8)!,
            keystore: keystore,
            account: userAddress!,
            password: keyStorePassword
        )
        
        let hashSignature = "0x" + (signature?.toHexString())!
        print("hashSignature:", hashSignature)
        
        let signee = Web3Utils.personalECRecover(tosHash.data(using: .utf8)!, signature: signature!)
        print("Recovered address:", signee as Any);
        
        let payload = RelayerPayload(tosHash: tosHash, from: userAddress!, signature: hashSignature)

        submitRelayRequest(object: payload)
        
        func submitRelayRequest(object: RelayerPayload) {
            do {
                let jsonData = try JSONEncoder().encode(object)
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
