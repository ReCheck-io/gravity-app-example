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

    let tosContract: String = "0x5DCC06c74BCaBb840B08F05399A44AEc3ED1bdD4"
    let relayContract: String = "0xaC4c847899f7A38b166DCcb83171eF4c19FD4c9C"
//    let tosContract: String = "0x3F06bAAdA68bB997daB03d91DBD0B73e196c5A4d"
//    let relayContract: String = "0x3F06bAAdA68bB997daB03d91DBD0B73e196c5A4d"
    let relayUrl: String = "https://gravity-relay.recheck.io/relay"
    let chainId: EIP712.UInt256 = .init(337)

    func getUserNonce(userAddress : EthereumAddress) throws -> EIP712.UInt256 {
        return .init(0)
    }

    func submitJson(object: RelayerPayload) {
        do {
            let jsonData = try JSONEncoder().encode(object)
            print(String(data: jsonData, encoding: .utf8) as Any)
            
            let url = URL(string: relayUrl)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            // insert json data to the request
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                
                print(String(data: data, encoding: .utf8) as Any)
                
            }

            task.resume()
        } catch {
            print(error)
        }
    }

    func signTerms(keystore: BIP32Keystore, keyStorePassword: String, termsHash : String, termsVersion : String) throws {
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
        
        let verifyingContract = EthereumAddress(relayContract)!
       
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
            verifyingContract: verifyingContract,
            account: userAddress!,
            password: keyStorePassword,
            chainId: chainId)
        
        print("signature: ", signature.toHexString())
        
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
        
        
        let payload = RelayerPayload(tx: safeTxObject, from: userAddress!, signature: "0xabf" + signature.toHexString())
        
        submitJson(object: payload)
    }


}
