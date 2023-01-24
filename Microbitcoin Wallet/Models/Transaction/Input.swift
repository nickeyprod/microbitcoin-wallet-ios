//
//  Input.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 05.08.2021.
//

import Foundation

struct Input {
    var prev_out: PrevOut
    var scriptSig: String?
}
