//
//  Transaction.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 04.06.2021.
//

import Foundation

struct Transaction {
    var hash: String?
    var ver: Int = 1
    var vin_sz: Int {
        return self.in.count
    }
    var vout_sz: Int {
        return self.out.count
    }
    var lock_time: Int = 0
    var size: Int = 0
    var `in`: [Input] = []
    var out: [Output] = []
}
