//
//  HDWallet.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 30.07.2021.
//

import Foundation
import CryptoKit
import Base58Swift
import OpenSSL
import BigInt


class HDWallet {
    
    var currIndex = 0
    var seed: String = ""
    var seedWordsCount = 0
    var currentMnemonic: [String] = []
    var masterPrivateKey: String = ""
    var masterPublicKey: String = ""
    var masterChainCode: String = ""
    
    var rootMasterPrivateKey: String = ""
    var rootMasterPublicKey: String = ""
    
    var possibleWords: [String] {
        if let startWordsURL = Bundle.main.url(forResource: "wordsList", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                return startWords.components(separatedBy: "\n")
            } else {
                fatalError("Couldn't proceed words list")
            }
        }
        fatalError("Couldn't find words list file")
    }
    
    func restoreWalletByMnemonic(mnemonic: String) {
        let mnemonicArray = mnemonicToArray(mnemonic: mnemonic)

        if (mnemonicArray.count < 24) {
            print("Mnemonic phrase cannot be less than 24 words")
        }
        
        let mnemonicValid = checkMnemonic(fullMnemonicArray: mnemonicArray)

        if (mnemonicValid != true) {
            print("This mnemonic phrase invalid")
        }
        
        // it's valid, proceed with this mnemonic
        currentMnemonic = mnemonicArray
     
        getSeedFromMnemonic()
        generateMasterKeys()
    }
    
    
    func mnemonicToString() -> String {
        return currentMnemonic.joined(separator: " ")
    }
    
    func mnemonicToArray(mnemonic: String) -> [String] {
        return mnemonic.components(separatedBy: " ")
    }
    
    func generateChildKeys(depth: String, index: String, key: String, chainCode: String) {
        
        let data: String = key + index
        
        let dataBytes = data.hexaBytes
        let chainCodeBytes = chainCode.hexaBytes
        
        var result = [UInt8](repeating: 0, count: 64)
   
        HMAC(EVP_sha512(), chainCodeBytes, Int32(chainCodeBytes.count), dataBytes, dataBytes.count, &result, nil)
        
        let leftSideAsHex = Data(result[0..<32]).hexEncodedString()
        let rightSideAsHex = Data(result[32...]).hexEncodedString()
        
        let childPrivateKeyPartAsHex = leftSideAsHex
        let childChainCodeAsHex = rightSideAsHex
        
        let childPrivateKeyPartAsNum = BigInt(childPrivateKeyPartAsHex, radix: 16)!
        let parentPrivateKeyAsNum = BigInt(masterPrivateKey, radix: 16)!
    
        // Order of a Curve
        let n = BigInt("115792089237316195423570985008687907852837564279074904382605163141518161494337")
        // Check that chain code is less than order of a curve
        if let childChainCodeBigInt = BigInt(childChainCodeAsHex, radix: 16) {
            if (childChainCodeBigInt >= n) {
                print("ERROR, Calculated chain code is greater than the order of the curve. Try the next index.")
            }
        } else {
            print("ERROR, Cannot init BigInt from provided child chain code")
        }
   
        let childPrivateKeyAsNum = (parentPrivateKeyAsNum + childPrivateKeyPartAsNum) % n
        let childPrivateKeyAsHex = String(childPrivateKeyAsNum, radix: 16)
        
        var childPrivateKeyBase58Encoded: String = "", childPublicKeyBase58Encoded: String = ""
        
        // Get parent key fingerprint from parent public
        let parentFingerprint = Data(CryptoHelpers.getRipemd160(from: masterPublicKey)[0...3]).hexEncodedString()
        
        if let childPublicKey = CryptoHelpers.getPublicKey(from: childPrivateKeyAsHex) {
            
            
            
            if let childPrivateKey = base58checkEncode(key: childPrivateKeyAsHex, chainCode: childChainCodeAsHex, parentFingerprint: parentFingerprint, depth: depth, keyIndex: index) {
                
                childPrivateKeyBase58Encoded = childPrivateKey
            }
            
            if let childPublicKey = base58checkEncode(key: childPublicKey, chainCode: childChainCodeAsHex, parentFingerprint: parentFingerprint, depth: depth, keyIndex: index) {
                
                childPublicKeyBase58Encoded = childPublicKey
            }
            
            
            print("Encoded pk: \(childPrivateKeyBase58Encoded)")
            print("Encoded pub key: \(childPublicKeyBase58Encoded)")
            
        } else {
            print("ERROR, Cannot get public key from provided private key")
        }
    }
    
    func generateMasterKeys() {
   
        var result = [UInt8](repeating: 0, count: 64)
        
        // Bitcoin seed as HEX - hexa bytes
        let btcSeed = "426974636f696e2073656564".hexaBytes
        
        let seedBytes = seed.hexaBytes
        
        HMAC(EVP_sha512(), btcSeed, Int32(btcSeed.count), seedBytes, seedBytes.count, &result, nil)
        
        masterPrivateKey = Data(result[0..<32]).hexEncodedString()
        masterChainCode = Data(result[32...]).hexEncodedString()
        
        if (BigInt(masterPrivateKey.hexaData) >= BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!) {
            print("ERROR, Private KEY is greater than the order of the curve. Try the next index.")
        }
        
        if (BigInt(masterChainCode.hexaData) >= BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!) {
            print("ERROR, Chain code is greater than the order of the curve. Try the next index.")
        }
        
        rootMasterPrivateKey = base58checkEncode(key: masterPrivateKey, chainCode: masterChainCode, parentFingerprint: "00000000", depth: "00", keyIndex: "00000000")!
        
        print("ROOT KEY: \(rootMasterPrivateKey)")
        
        masterPublicKey = CryptoHelpers.getPublicKey(from: masterPrivateKey)!
        
        rootMasterPublicKey = base58checkEncode(key: masterPublicKey, chainCode: masterChainCode, parentFingerprint: "00000000", depth: "00", keyIndex: "00000000")!
        
        print("ROOT PUBLIC: \(rootMasterPublicKey)")
        
//        generateChildKeys(depth: "01", index: "00000000", key: masterPublicKey, chainCode: masterChainCode)
        
    }
    
    
    
    func base58checkEncode(key: String, chainCode: String, parentFingerprint: String, depth: String, keyIndex: String) -> String? {
    
        var hexToSerialize = ""
        
        // if length of the key 64 - its private key, else public
        if (key.count == 64) {
            let networkType = CryptoConstants.prefixes["prv_bip32"]!
            hexToSerialize = networkType + depth + parentFingerprint + keyIndex + chainCode + "00" + key
        }
        else if (key.count == 66) {
            let networkType = CryptoConstants.prefixes["pub_bip32"]!
            hexToSerialize = networkType + depth + parentFingerprint + keyIndex + chainCode + key
        } else {
            print("Key Invalid")
            return nil
        }
        
        let doubleSHA = SHA256.hash(data: hexToSerialize.hexaBytes).withUnsafeBytes { data2 in
            return SHA256.hash(data: data2)
        }
        
        hexToSerialize = hexToSerialize + doubleSHA.hexStr.prefix(8)

        let result = Base58.base58Encode(hexToSerialize.hexaToBytes)
        
        return result
    }
    

   func bip32ExtendedKeyDecode(key: String) -> [String: String]? {
       if let decodedString = Base58.base58Decode(key) {
           let decodedHEXString = Data(decodedString).hexEncodedString()
           
           var decodedData: [String: String] = [:]
           
           var from = String.Index(utf16Offset: 0, in: decodedHEXString)
           var to = String.Index(utf16Offset: 8, in: decodedHEXString)
           
           let networkPrefix = String(decodedHEXString[from..<to])
           decodedData["networkPrefix"] = networkPrefix
           
           from = String.Index(utf16Offset: 8, in: decodedHEXString)
           to = String.Index(utf16Offset: 10, in: decodedHEXString)
           
           let depth = String(decodedHEXString[from..<to])
           decodedData["depth"] = depth
           
           from = String.Index(utf16Offset: 10, in: decodedHEXString)
           to = String.Index(utf16Offset: 18, in: decodedHEXString)
           
           let parentFingerprint = String(decodedHEXString[from..<to])
           decodedData["parentFingerprint"] = parentFingerprint
           
           from = String.Index(utf16Offset: 18, in: decodedHEXString)
           to = String.Index(utf16Offset: 26, in: decodedHEXString)
           
           let keyIndex = String(decodedHEXString[from..<to])
           decodedData["keyIndex"] = keyIndex
           
           from = String.Index(utf16Offset: 26, in: decodedHEXString)
           to = String.Index(utf16Offset: 90, in: decodedHEXString)
           
           let chainCode = String(decodedHEXString[from..<to])
           decodedData["chainCode"] = chainCode
           
           from = String.Index(utf16Offset: 90, in: decodedHEXString)
           to = String.Index(utf16Offset: 156, in: decodedHEXString)
           
           let someKey = String(decodedHEXString[from..<to])
           
        if (networkPrefix == CryptoConstants.prefixes["prv_bip32"]) {
               decodedData["privateKey"] = String(someKey.suffix(64))
           } else if (networkPrefix == CryptoConstants.prefixes["pub_bip32"]) {
               decodedData["publicKey"] = someKey
           }
           
           from = String.Index(utf16Offset: 156, in: decodedHEXString)
           to = String.Index(utf16Offset: 164, in: decodedHEXString)
           
           decodedData["checksum"] = String(decodedHEXString[from..<to])
           
           return decodedData
       } else {
           print("Couldn't decode extended private key")
       }
       return nil
   }
       

    func getSeedFromMnemonic() {
        currentMnemonic = mnemonicToArray(mnemonic: "hungry excuse ancient satoshi west hold grain smooth tray armed render erosion hub win muffin unknown promote runway kite clinic tank hospital silk blossom")
        let mnemonic = mnemonicToString()
 
        var result = [UInt8](repeating: 0, count: 64)
        
        let a = "mnemonic".uInt8Array()
        let c = mnemonic.int8Array()

        guard 1 == PKCS5_PBKDF2_HMAC(c, Int32(c.count), a, Int32(a.count), 2048, EVP_sha512(), 64, &result) else {
            print("Error generating HMAC")
            return
        }
        
        let d = Data(result)
        
        seed = d.hexEncodedString()
        print("Seed: \(seed)")
        
  
    }
    
    func checkMnemonic(fullMnemonicArray: [String]) -> Bool {
    
        var wordIndexes: [Int] = []
        
        // Find index for every word in array
        for word in fullMnemonicArray {
            if let wordIndex = possibleWords.firstIndex(of: word) {
                wordIndexes.append(wordIndex)
            } else {
                return false
            }
        }

        // Convert word Indexes Numbers to their Binary representation
        
        var wordIndexesBits: [String] = []
        
        for i in wordIndexes {
            let indexAsBinaryString = String(i, radix: 2)
            wordIndexesBits.append(indexAsBinaryString)
        }

        // Correct binary and add zeros at the start if needed
        
        let wordIndexesBitsWithZeros = wordIndexesBits.map({ CryptoHelpers.addZeros(bin: $0) })
        
        // Join array of String bits to single string of bits
        
        let singleStringOfBits = wordIndexesBitsWithZeros.joined(separator: "").prefix(256)
        
        // convert string of bits to Bit s
        
        var entropyOfBits: [Bit] = []
        
        for char in singleStringOfBits {
            if char == "0" {
                entropyOfBits.append(Bit.zero)
            } else {
                entropyOfBits.append(Bit.one)
            }
        }

        // Convert string of bits to data
        
        let stringOfBitsAsData = CryptoHelpers.bitsToBytes(bits: entropyOfBits)
        
        // Calculate hash of the string of bits
        
        let sha256Hash = SHA256.hash(data: stringOfBitsAsData)
            
        // Get checksum
    
        let arrayFromStr = Array(sha256Hash.hexStr)
        let checksumHexa = String(arrayFromStr[0...1])
        let checksumBinary = checksumHexa.hexaToBinary
    

        // Add checksum bits to the end of the entropy of bits
        
        let entropyOfBitsExtended = singleStringOfBits + checksumBinary
        let entropyOfBitsExtendedArray = Array(entropyOfBitsExtended)
      

        var b1 = 0, b2 = 10

        var mnemonicNumbers:[Int] = []

        for _ in 0...23 {
            let word = entropyOfBitsExtendedArray[b1...b2]
            var w: String = ""
            for k in word {
                w += k.description

            }

            if let number = Int(w, radix: 2) {
                mnemonicNumbers.append(number)
            }

            b1 += 11
            b2 += 11
        }

        if (wordIndexes[wordIndexes.count - 1] == mnemonicNumbers[mnemonicNumbers.count - 1]) {
            return true
        } else {
            return false
        }

    }
    
    
     func generateMnemonic() {
         
         // Generate 32 random bytes
        let entropyOfBytes = CryptoHelpers.generateRandomBytes()!
         
         let sha256 = SHA256.hash(data: entropyOfBytes)
         let entropyAsBinary = sha256.hexStr.hexaToBinary
         let entropyAsData = sha256.hexStr.hexaData
         
         // Calculate SHA256 of the entropy
     
         let sha256Hash = SHA256.hash(data: entropyAsData)
         
         let arrayFromStr = Array(sha256Hash.hexStr)
         let checksumHexa = String(arrayFromStr[0...1])
         let checksumBinary = checksumHexa.hexaToBinary

         // Add checksum bits to the end of the entropy of bits
         
         let entropyOfBitsExtended = entropyAsBinary + checksumBinary
         let entropyExtendedArray = Array(entropyOfBitsExtended)
         
         var n1 = 0, n2 = 10

         var mnemonicWordIndexes:[Int] = []

         for _ in 0...23 {
             let word = entropyExtendedArray[n1...n2]
             var w: String = ""
             for k in word {
                 w += k.description

             }

             if let number = Int(w, radix: 2) {
                 mnemonicWordIndexes.append(number)
             }

             n1 += 11
             n2 += 11
         }
         
         // Clear previous if exist
         currentMnemonic.removeAll()

         // Add actual words to mnemonic array

         for num in mnemonicWordIndexes {
             currentMnemonic.append(possibleWords[num])
         }
         
         print("Current mnemonic: \(mnemonicToString())")
     }
}

extension String {

    typealias Byte = UInt8
    var hexaToBytes: [Byte] {
        var start = startIndex
        return stride(from: 0, to: count, by: 2).compactMap { _ in   // use flatMap for older Swift versions
            let end = index(after: start)
            defer { start = index(after: end) }
            return Byte(self[start...end], radix: 16)
        }
    }
    
    func int8Array() -> [Int8] {
        var retVal : [Int8] = []
        for thing in self.utf8 {
            retVal.append(Int8(thing))
        }
        return retVal
    }

    func uInt8Array() -> [UInt8] {
        var retVal : [UInt8] = []
        for thing in self.utf8 {
            retVal.append(UInt8(thing))
        }
        return retVal
    }
    
    var hexaToBinary: String {
          return hexaToBytes.map {
              let binary = String($0, radix: 2)
              return repeatElement("0", count: 8-binary.count) + binary
          }.joined()
      }
  

}
