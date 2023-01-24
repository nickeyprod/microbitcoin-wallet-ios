//
//  Extensions.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 30.07.2021.
//

import Foundation




//func bits(fromByte byte: UInt8) -> [Bit] {
//    var byte = byte
//    var bits = [Bit](repeating: .zero, count: 8)
//    for i in 0..<8 {
//        let currentBit = byte & 0x01
//        if currentBit != 0 {
//            bits[i] = .one
//        }
//
//        byte >>= 1
//    }
//
//    return bits
//}
//
//
//
//extension String {
//
//    typealias Byte = UInt8
//    var hexaToBytes: [Byte] {
//        var start = startIndex
//        return stride(from: 0, to: count, by: 2).compactMap { _ in   // use flatMap for older Swift versions
//            let end = index(after: start)
//            defer { start = index(after: end) }
//            return Byte(self[start...end], radix: 16)
//        }
//    }
//
//    var hexaToBinary: String {
//        return hexaToBytes.map {
//            let binary = String($0, radix: 2)
//            return repeatElement("0", count: 8-binary.count) + binary
//        }.joined()
//    }
//
//    func int8Array() -> [Int8] {
//        var retVal : [Int8] = []
//        for thing in self.utf8 {
//            retVal.append(Int8(thing))
//        }
//        return retVal
//    }
//
//    func uInt8Array() -> [UInt8] {
//        var retVal : [UInt8] = []
//        for thing in self.utf8 {
//            retVal.append(UInt8(thing))
//        }
//        return retVal
//    }
//
//    func toUnsafeMutablePointerUInt8() -> UnsafeMutablePointer<UInt8>? {
//        guard let data = self.data(using: .utf8) else {
//            return nil
//        }
//
//        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
//        let stream = OutputStream(toBuffer: buffer, capacity: data.count)
//        stream.open()
//        let value = data.withUnsafeBytes {
//            $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
//        }
//        guard let val = value else {
//            return nil
//        }
//        stream.write(val, maxLength: data.count)
//        stream.close()
//
//        return UnsafeMutablePointer<UInt8>(buffer)
//    }
//
//    func toUnsafePointerUInt8() -> UnsafePointer<UInt8>? {
//        guard let data = self.data(using: .utf8) else {
//            return nil
//        }
//
//        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
//        let stream = OutputStream(toBuffer: buffer, capacity: data.count)
//        stream.open()
//        let value = data.withUnsafeBytes {
//            $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
//        }
//        guard let val = value else {
//            return nil
//        }
//        stream.write(val, maxLength: data.count)
//        stream.close()
//
//        return UnsafePointer<UInt8>(buffer)
//    }
//
//
//}
//
