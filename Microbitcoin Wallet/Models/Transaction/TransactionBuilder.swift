//
//  TransactionBuilder.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 30.07.2021.
//

import Foundation
import OpenSSL
import BigInt


class TransactionBuilder {
    
    // Input's P2PKS script contains two components, a signature and a public key.
        
    // scriptPubKey: OP_DUP OP_HASH160 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG - prev tx (locking script)
    // scriptSig: <sig> <pubKey> - spender of funds (unlocking script)
        
    // OP_HASH160 - public key hashed first with SHA-256 and then with RIPEMD-160.
    
    static func generateSignatureRandomNumbers() -> (BigUInt, String)? {
        // generate random 32 bytes
        let randomBytes = CryptoHelpers.generateRandomBytes()!
        // convert them to BigUInt
        let initialRandomNum = BigUInt(Data(randomBytes).hexEncodedString(), radix: 16)!
        
        let randomNumAsHex = String(initialRandomNum, radix: 16)
        
        // empty var for storing it as OpenSSL's BIGNUM
        var randomBigNum = BN_new()
        
        // convert random number hex string to BIGNUM
        guard 0 != BN_hex2bn(&randomBigNum, randomNumAsHex) else {
            print("Error creating BIGNUM from string")
            return nil
        }
        
        // create new secp256k1 EC_GROUP
        guard let group = EC_GROUP_new_by_curve_name(NID_secp256k1) else {
            print("Error during creating EC_GROUP")
            return nil
        }
        
        // initialize new empty EC_POINT object to store result of EC_POINT_mul (actual public key)
        guard let r = EC_POINT_new(group) else {
            print("Error during initializing new empty EC_POINT object")
            return nil
        }
        
        // get new ec point from Big Num and store it to r variable
        guard 1 == EC_POINT_mul(group, r, randomBigNum, nil, nil, nil) else {
            print("Error getting public key from private key")
            return nil
        }
        
        // convert EC_POINT object to BIGNUM OpaquePointer
        guard let pointerToRandomBigNum = EC_POINT_point2bn(group, r, POINT_CONVERSION_UNCOMPRESSED, nil, nil) else {
            print("Error converting EC_POINT object to BIGNUM")
            return nil
        }
        
        // convert BIGNUM to HEX pointer
        let randomNumHexPointer = BN_bn2hex(pointerToRandomBigNum)
        
        // convert pointer to normal string
        let normalStringRNum = String(cString: randomNumHexPointer!)
        
        return (initialRandomNum, normalStringRNum)
    }
    
    static func getSignature(for privateKey: String, and txHash: String) -> String? {
        // First, generate random numbers
        guard let randomNums = TransactionBuilder.generateSignatureRandomNumbers() else {
            print("Error during generating random number")
            return nil
        }
        
        // get x coordinate from it
        let xCoord = TransactionBuilder.getXCoordinate(from: randomNums.1)
        
        // take private key and multiply by x coordinate
        let pkBigNum = BigUInt(privateKey, radix: 16)!
        let xCoordBigNum = BigUInt(xCoord, radix: 16)!
        // multiply private key to X coordinate
        let firstMultiply = pkBigNum * xCoordBigNum
        // convert result to hex
        let resultHex = Data(String(firstMultiply).utf8).map{ String(format:"%02x", $0) }.joined()
        
        // concatenate result and tx hash
        let concatenatedData = resultHex + txHash // concatenate
        // convert extended result to Big Int
        let extendedResultBigNum = BigUInt(concatenatedData, radix: 16)!
        // divide extended Big Int result on our initial random number to get signature
        let signature = extendedResultBigNum / randomNums.0
        print("Signature: \(signature)")
        return String(signature)
    }
    
    static func getXCoordinate(from ecPoint: String) -> String {

        let z = ecPoint.prefix(2)
        let newEC = ecPoint.suffix(128)
        let y = newEC.suffix(64)
        let x = newEC.prefix(64)
        print("X: \(x)")
        print("Y: \(y)")
        print("Z: \(z)")
        return String(x)
    }
    
    static func createTransaction(spendableTxId: String, spendableOutputNum: Int, value: Int) -> Transaction? {
        let input = Input(prev_out: PrevOut(hash: spendableTxId, n: spendableOutputNum))
        var tx = Transaction()
        tx.in.append(input)
        print(tx)
        return tx
    }
    
    // [P2PKH] - Pay-To-Public-Key-Hash - old way of tx
    func scriptPubKey(with publicKey: String) -> String? {
        let pubKeyHash = CryptoHelpers.getRipemd160(from: publicKey)
        let scriptPubKey = "OP_DUP OP_HASH160 \(pubKeyHash) OP_EQUALVERIFY OP_CHECKSIG"
        return scriptPubKey
    }
    
    // [P2SH] - Pay-to-Script-Hash - new way of tx
    static func scriptPubKey2(with publicKey: String) -> String? {
        let redeemScript = "\(publicKey) OP_CHECKSIG"
        let scriptHash = CryptoHelpers.getRipemd160(from: redeemScript)
        print(Data(scriptHash).hexEncodedString())
        let scriptPubKey = "OP_HASH160 \(scriptHash) OP_EQUAL"
        return scriptPubKey
    }
}


extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
    
}
