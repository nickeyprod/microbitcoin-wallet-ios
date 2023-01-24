//
//  Tx.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 05.08.2021.
//

import Foundation

struct Tx: Hashable {
    let amount: Double
    let timestamp: Int?
}
