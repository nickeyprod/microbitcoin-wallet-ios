//
//  TxDetailsResults.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 06.04.2021.
//

import Foundation

struct TxDetailsResults: Decodable {
    let error: String?;
    let id: String;
    let result: TransactionDetails;
}

enum VInType {

    case scriptObj([ScriptObj]), coinbaseTx([CoinbaseTx])
}

struct TransactionDetails: Decodable {


    let amount: Int;
    let confirmations: Int;
    let blocktime: Int?;
    let vin: VInType;
    let vout: [ScriptObj];
    
    private enum CodingKeys : String, CodingKey {
        case amount, confirmations, blocktime, vin, vout
    }
    
    init(from decoder : Decoder) throws {

            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.amount = try container.decode(Int.self, forKey: .amount)
            self.confirmations = try container.decode(Int.self, forKey: .confirmations)
            self.blocktime = try container.decode(Int.self, forKey: .blocktime)
            self.vout = try container.decode([ScriptObj].self, forKey: .vout)
        
            do {
                let scriptObjData =  try container.decode([ScriptObj].self, forKey: .vin)
                self.vin = .scriptObj(scriptObjData)
            } catch {
                let coinbaseTxData = try container.decode([CoinbaseTx].self, forKey: .vin)
                self.vin = .coinbaseTx(coinbaseTxData)
            }
           
        }
}

struct ScriptObj: Decodable, Hashable  {
    let n: Int?;
    let scriptPubKey: ScriptPubKey;
    let value: Int;
    var blocktime: Int?;
    var type: String?;
}

struct ScriptPubKey: Decodable, Hashable {
    let addresses: [String];
}

struct CoinbaseTx: Decodable {
    let coinbase: String;
    let sequence: Int;
    var type: String?;
}


