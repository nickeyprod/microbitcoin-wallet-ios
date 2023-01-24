//
//  BalanceResults.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 04.04.2021.
//

import Foundation

struct BalanceResults: Decodable {
    let error: String?;
    let id: String;
    let result: Balance;
}

struct Balance: Decodable {
    let balance: Int;
    let locked: Int;
    let received: Int;
}
