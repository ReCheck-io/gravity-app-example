//
//  SHA256.swift
//  near-example
//
//  Created by Byurhan Beyzat on 20.10.22.
//

import CryptoSwift

struct AES256 {
//    Change encryptionIV to any random 16 chars
    let encryptionIV: String = "6L82f!#364&%9$86";

    public func encryptString(pin: String, data: String) -> String {
        let encryptedData: String = try! data.aesEncrypt(key: pin, iv: encryptionIV)
//        print("Data: ", data)
//        print("Encrypted Data: ", encryptedData)
        
        return encryptedData
    }

    public func decryptString(pin: String, encryptedString: String) -> String {
        let dencryptedData: String = try! encryptedString.aesDecrypt(key: pin, iv: encryptionIV)
//        print("Encrypted Data: ", encryptedString)
//        print("Decrypted Data: ", dencryptedData)
        
        return dencryptedData
    }
}

extension String{
    func aesEncrypt(key: String, iv: String) throws -> String {
        let data = self.data(using: .utf8)!
        let encrypted = try! AES(key: Array(key.utf8), blockMode: CBC.init(iv: Array(iv.utf8)), padding: .pkcs7).encrypt([UInt8](data));
        let encryptedData = Data(encrypted)
        return encryptedData.base64EncodedString()
    }
    
    func aesDecrypt(key: String, iv: String) throws -> String {
        let data = Data(base64Encoded: self)!
        let decrypted = try! AES(key: Array(key.utf8), blockMode: CBC.init(iv: Array(iv.utf8)), padding: .pkcs7).decrypt([UInt8](data));
        let decryptedData = Data(decrypted)
        return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
    }
}
