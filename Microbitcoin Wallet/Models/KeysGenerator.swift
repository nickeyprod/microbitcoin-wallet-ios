//
//  KeysGenerator.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 05.06.2021.
//

//  This product includes software developed by the OpenSSL Project
//  for use in the OpenSSL Toolkit (http://www.openssl.org/)

import Foundation
import CryptoKit
import BigInt

class KeysGenerator {
    
    func generateNewKeys() -> KeyPair? {
        guard let privateKey = generateNewPrivateKey() else {
            print("Error generating new private key")
            return nil
        }
        guard let publicKey = CryptoHelpers.getPublicKey(from: privateKey) else {
            print("Error getting public key from private key")
            return nil
        }
        
        let newKeyPair = KeyPair(privateKey: privateKey, publicKey: publicKey)
 
        return newKeyPair
    }

    func generateNewPrivateKey() -> String? {

        let BIG_INT = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!

        var randomBigInt: BigUInt
        var sha256FromBytes: SHA256Digest

        if let randomBytes = CryptoHelpers.generateRandomBytes() {
            repeat {
                sha256FromBytes = SHA256.hash(data: randomBytes)
                randomBigInt = BigUInt(sha256FromBytes.hexStr, radix: 16)!
                
            } while (randomBigInt == BigUInt.zero || randomBigInt == BigUInt(1) || randomBigInt > BIG_INT)
   
            return String(randomBigInt, radix: 16)
        } else {
            print("Error during generating random bytes")
        }
        
        return nil
    }
}

extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }

    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}
