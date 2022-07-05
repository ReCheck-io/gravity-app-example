//
//  EIP712.swift
//  web3-demo
//
//  Created by Emil Stoyanov on 29.06.22.
//

import Foundation
import web3swift

struct RelayerPayload: Codable {
    let tx: SafeTxStr
    let from: EthereumAddress
    let signature: String
}


class GEIP712 {
    
//    this combo works
//    let relayContract: String = "0xaC4c847899f7A38b166DCcb83171eF4c19FD4c9C"
//    let tosContract: String = "0x3F06bAAdA68bB997daB03d91DBD0B73e196c5A4d"
    
    let tosContract: String = "0x5DCC06c74BCaBb840B08F05399A44AEc3ED1bdD4"
    let relayContract: String = "0xaC4c847899f7A38b166DCcb83171eF4c19FD4c9C"
    
//    let tosContract: String = "0x3F06bAAdA68bB997daB03d91DBD0B73e196c5A4d"
//    let relayContract: String = "0x3F06bAAdA68bB997daB03d91DBD0B73e196c5A4d"
    let relayUrl: String = "https://gravity-relay.recheck.io"
    let chainId: EIP712.UInt256 = .init(337)

    func getUserNonce(userAddress: EthereumAddress) throws -> EIP712.UInt256 {
        let url = relayUrl + "/nonce"
        var components = URLComponents(string: url)!
        components.queryItems = [URLQueryItem(name: "account", value: userAddress.address)]
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")

        var request = URLRequest(url: components.url!)

        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var nonceValue = 0;
        
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
            print("Nonce response: ", responseObject as Any)
            
            nonceValue = (responseObject?["result"] as? NSString)?.integerValue ?? 0
        }

        task.resume()
        
        return .init(nonceValue)
    }

    func submitJson(object: RelayerPayload) {
        do {
            let jsonData = try JSONEncoder().encode(object)
//            print("Request Body: ", object)
            
            let url = URL(string: relayUrl + "/relay")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            // insert json data to the request
            request.httpBody = jsonData

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

    func signTerms(keystore: BIP32Keystore, keyStorePassword: String, termsHash: String, termsVersion: String) throws {
        let userAddress = keystore.addresses?[0]
        let to = EthereumAddress(tosContract)!
        let value = EIP712.UInt256(0)

        let function = ABI.Element.Function(
            name: "signTerms",
            inputs: [
                .init(name: "termsHash", type: .string),
                .init(name: "termsVersion", type: .string)],
            outputs: [],
            constant: false,
            payable: false)

        let object = ABI.Element.function(function)

        let safeTxData = object.encodeParameters([
            termsHash as AnyObject,
            termsVersion as AnyObject
        ])!

        let nonce: EIP712.UInt256 = try! getUserNonce(userAddress: userAddress!)
        
        let operation: EIP712.UInt8 = 1
        let baseGas = EIP712.UInt256("60000")
        let safeTxGas = EIP712.UInt256("250000")
        let gasPrice = EIP712.UInt256("20000000000")
        let gasToken = EthereumAddress("0x0000000000000000000000000000000000000000")!
       
        let safeTX = SafeTx(
            to: to,
            value: value,
            data: safeTxData,
            operation: operation,
            safeTxGas: safeTxGas,
            baseGas: baseGas,
            gasPrice: gasPrice,
            gasToken: gasToken,
            refundReceiver: userAddress!,
            nonce: nonce)

        let signature = try Web3Signer.signEIP712(
            safeTx: safeTX,
            keystore: keystore,
            verifyingContract: EthereumAddress(relayContract)!,
            account: userAddress!,
            password: keyStorePassword,
            chainId: chainId)
            
//            name: "AwlForwarder",
//            version: "1",
//            typeHash: safeTX.encodeType()
//            ForwardRequest(address to,uint256 value,bytes data,uint8 operation,uint256 safeTxGas,uint256 baseGas,uint256 gasPrice,address gasToken,address refundReceiver,uint256 nonce)
        
//        print("TypeHash", safeTX.encodeType())
        

        let safeTxObject = SafeTxStr(
            to: to,
            value: value,
            data: safeTxData,
            operation: operation,
            safeTxGas: safeTxGas,
            baseGas: baseGas,
            gasPrice: gasPrice,
            gasToken: gasToken,
            refundReceiver: userAddress!,
            nonce: nonce)
        
        let payload = RelayerPayload(tx: safeTxObject, from: userAddress!, signature: "0x" + signature.toHexString())
        
        submitJson(object: payload)
    }
}
