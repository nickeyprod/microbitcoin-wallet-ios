//
//  Helpers.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 05.04.2021.
//

import Foundation

class Helpers {
    func handleBalanceDisplaying(balance: Double) -> String {
        // Move decimal place 4 characters to left and convert it to string
        let balanceStr = String(Double(balance) / 10000)
        return balanceStr.split(separator: ".").joined(separator: ",")
    }
}

