//
//  TxHistoryResults.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 06.04.2021.
//

import Foundation

struct TxHistoryResults: Decodable {
    let error: String?;
    let id: String;
    let result: txHistory;
}

struct txHistory: Decodable {
    let tx: [String];
    let txcount: Int;
}
