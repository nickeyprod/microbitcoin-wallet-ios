//
//  CryptoHelpers.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 30.07.2021.
//

import Foundation
import CryptoKit
import OpenSSL
import Base58Swift
import BigInt

class CryptoHelpers {
    
    // Generating cryptographically secured 32 random bytes
    static func generateRandomBytes() -> [UInt8]? {
        var bytes = [UInt8](repeating: 0, count: 32)
        let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        
        guard result == errSecSuccess else {
            print("Problem generating random bytes")
            return nil
        }
        return bytes
    }
    
    // Hashing public key with SHA256, then RIPEMD160
    static func getRipemd160(from publicKey: String) -> [UInt8] {
        
        var md = [UInt8](repeating: 0, count: Int(RIPEMD160_DIGEST_LENGTH))
        
        let sha256Digest = SHA256.hash(data: publicKey.hexaBytes)
        
        RIPEMD160(sha256Digest.bytes, 32, &md)
        
        return md
    }
    
    // Getting public key from provided master key
    static func getPublicKey(from privateKey: String) -> String? {

        // create new secp256k1 EC_GROUP
        guard let group = EC_GROUP_new_by_curve_name(NID_secp256k1) else {
            print("Error during creating EC_GROUP")
            return nil
        }
        
        // intialize new binary context
        guard let ctx = BN_CTX_new() else {
            print("Error during initializing new BN_CTX structure")
            return nil
        }
        
        // private key to big num
        var privateBN = BN_new()
        
        // convert private key string to BIGNUM
        guard 0 != BN_hex2bn(&privateBN, privateKey) else {
            print("Error creating BIGNUM from string")
            return nil
        }
        
        // initialize new empty EC_POINT object to store result of EC_POINT_mul (actual public key)
        guard let pub = EC_POINT_new(group) else {
            print("Error during initializing new empty EC_POINT object")
            return nil
        }
        
        // get actual public key from private key and store it to pub variable
        guard 1 == EC_POINT_mul(group, pub, privateBN, nil, nil, ctx) else {
            print("Error getting public key from private key")
            return nil
        }
        
        // convert EC_POINT object to BIGNUM OpaquePointer
        guard let pointerToPubKeyBigNum = EC_POINT_point2bn(group, pub, POINT_CONVERSION_COMPRESSED, nil, ctx) else {
            print("Error converting EC_POINT object to BIGNUM")
            return nil
        }
        
        let publicKeyHex = BN_bn2hex(pointerToPubKeyBigNum);
        
        return String(cString: publicKeyHex!)
    }
    
    // Converting provided array of Bits to Bytes array
    static func bitsToBytes(bits: [Bit]) -> [UInt8] {
        let numBits = bits.count
        let numBytes = (numBits + 7)/8
        var bytes = [UInt8](repeating: 0, count : numBytes)

        for (index, bit) in bits.enumerated() {
            if bit == .one {
                bytes[index / 8] += 1 << (7 - index % 8)
            }
        }

        return bytes
    }
    
    // Adding zeros at the start of provided binary number for them to be all equal 11 bits length
     static func addZeros(bin: String) -> String {
        var newBin = bin
        while newBin.count != 11 {
            newBin = "0" + newBin
        }
        return newBin
    }
    
    static func base58CheckEncode(payload: [UInt8], verPrefix: String) -> [UInt8] {
        
        // Firstly, add version prefix to payload
        let prefPayload = verPrefix.hexaBytes + payload
        
        // Secondary, double SHA256 versionAndPayload string
        let doubleSHA = SHA256.hash(data: prefPayload).withUnsafeBytes { bfPtr in
            return SHA256.hash(data: bfPtr)
        }
        
        // Next, take first 4 bytes of the double SHA256
        let checksum = doubleSHA.bytes[0..<4]
        
        // And add them as checksum to the extended RIPEMD hash bytes
        let final = prefPayload + checksum
        
        return final
    }
    
    static func getBTCAddress(from publicKey: String) -> String {
        let ripemd160Bytes = CryptoHelpers.getRipemd160(from: publicKey)
        let base58check = CryptoHelpers.base58CheckEncode(payload: ripemd160Bytes, verPrefix: CryptoConstants.prefixes["btc_pub"]!)
        let newAddres = Base58.base58Encode(base58check)
        return newAddres
    }
    
    
    static func getMBCAddress(from publicKey: String) -> String {
        let ripemd160Bytes = CryptoHelpers.getRipemd160(from: publicKey)
        let base58check = CryptoHelpers.base58CheckEncode(payload: ripemd160Bytes, verPrefix: CryptoConstants.prefixes["mbc_pub"]!)
        let newAddres = Base58.base58Encode(base58check)
        return newAddres
    }
    
}

// ====== Extensions ======

enum Bit: UInt8, CustomStringConvertible {
    case zero, one

    var description: String {
        switch self {
        case .one:
            return "1"
        case .zero:
            return "0"
        }
    }
}

extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}
