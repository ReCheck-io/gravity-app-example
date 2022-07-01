//
//  EIP712.swift
//  web3-demo
//
//  Created by Emil Stoyanov on 29.06.22.
//

import Foundation
import web3swift


class GEIP712 {

    let tosContract: String = "0x3F06bAAdA68bB997daB03d91DBD0B73e196c5A4d"
    let relayContract: String = "0x3F06bAAdA68bB997daB03d91DBD0B73e196c5A4d"
    let relayUrl: String = "https://gravity-relay.recheck.io"
    let chainId : EIP712.UInt256 = .init(337)
    
    func getUserNonce(userAddress : EthereumAddress) throws -> EIP712.UInt256 {
        return .init(0)
    }
    
    func submitJson(object: SafeTx) {
        let jsonData = try JSONEncoder().encode(object)
        // create post request
        let url = URL(string: relayUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // insert json data to the request
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }

        task.resume()

    }
    
    func signTerms(keystore: BIP32Keystore, keyStorePassword: String, userAddress: EthereumAddress, termsHash : String, termsVersion : String) throws {
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
        
        let safeTxGas = EIP712.UInt256(250000)
        
        let nonce: EIP712.UInt256 = try! getUserNonce(userAddress: userAddress)
        
        let baseGas = EIP712.UInt256(60000)

        let gasPrice = EIP712.UInt256("20000000000")

        let gasToken = EthereumAddress("0x0000000000000000000000000000000000000000")!

        let operation: EIP712.UInt8 = 1

        let verifyingContract = EthereumAddress(relayContract)!

        let account = keystore.addresses?[0]

        let safeTX = SafeTx(
            to: to,
            value: value,
            data: safeTxData,
            operation: operation,
            safeTxGas: safeTxGas,
            baseGas: baseGas,
            gasPrice: gasPrice,
            gasToken: gasToken,
            refundReceiver: userAddress,
            nonce: nonce)
        
        let signature = try Web3Signer.signEIP712(
            safeTx: safeTX,
            keystore: keystore,
            verifyingContract: verifyingContract,
            account: account!,
            password: keyStorePassword,
            chainId: chainId)
        
        
    }
    
    
}
