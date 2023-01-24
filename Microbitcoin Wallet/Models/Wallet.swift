//
//  Wallet.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 04.04.2021.
//

//  This product includes software developed by the OpenSSL Project
//  for use in the OpenSSL Toolkit (http://www.openssl.org/)

import Foundation
import CryptoKit

class Wallet: HDWallet, ObservableObject  {
    
    @Published var addresses: [String] = []
    @Published var currentAddress: String = ""
    @Published var balance: String = "Loading.."
    @Published var transactionsHashes: [String] = []
    @Published var transactions: [Tx] = []
    @Published var balanceLoaded = false
    
    let ROOT_ENDPOINT =  "https://api.mbc.wiki"
    
    let helpers = Helpers()
    
    var txNumParsed = 0

    
    //   ----------= START addNewAddress() =----------
    
    func addNewAddress(address: String) {
        addresses.append(address)
        
        if let i = addresses.firstIndex(of: address) {
            currentAddress = addresses[i]
        }
        
        print("===== NEW ADDRESS ADDED ===== :")
        print(currentAddress)
    }
    
    
    //    ----------= START getAddressBalance() =----------
    
    func getAddressBalance() {
        if let url = URL(string: "\(ROOT_ENDPOINT)/balance/\(currentAddress)") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder();
                    if let safeData = data {
                        do {
                            let decodedResp = try decoder.decode(BalanceResults.self, from: safeData);
                            DispatchQueue.main.async {
                                if decodedResp.error != nil {
                                    self.balance = "Loading Error"
                                    return
                                }
                                self.balance = self.helpers.handleBalanceDisplaying(balance: Double(decodedResp.result.balance))
                                self.balanceLoaded = true
                            }
                        } catch {
                            self.balance = "Loading Error"
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    //    ----------= START getAddressTransactions() =----------
    
    func getAddressTransactions() {
        if let url = URL(string: "\(ROOT_ENDPOINT)/history/\(currentAddress)") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let decodedResp = try decoder.decode(TxHistoryResults.self, from: safeData);
                            DispatchQueue.main.async {
                                if decodedResp.error != nil {
                                    return
                                }
                                let txHashes = decodedResp.result.tx
                                if txHashes.count > 0 {
                                    self.transactionsHashes = txHashes
                                    self.getTransactionDetails(txHash: self.transactionsHashes[self.txNumParsed])
                                }
                            }
                        } catch {
                            print(error)
                        }
                        
                    }
                }
            }
            task.resume()
        }
    }
    
    
    //    ----------= START getTransactionDetails() =----------
    
    func getTransactionDetails(txHash: String) {
        if let url = URL(string: "\(ROOT_ENDPOINT)/transaction/\(txHash)") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let decodedResp = try decoder.decode(TxDetailsResults.self, from: safeData)
                            DispatchQueue.main.async {
                                if decodedResp.error != nil {
                                    print("API return error")
                                    return
                                }
                                let txDetails = decodedResp.result
                                let vout = txDetails.vout
                                let vin = txDetails.vin
                        
                                let txMBCAmount = self.getMBCAmount(vin: vin, vout: vout)
                                self.transactions.append(Tx(amount: txMBCAmount, timestamp: txDetails.blocktime))
                                
                                if self.txNumParsed < self.transactionsHashes.count {
                                    self.getTransactionDetails(txHash: self.transactionsHashes[self.txNumParsed])
                                } 
                            }
                        } catch {
                            print(error)
                        }
                        
                    }
                    
                }
            }
            task.resume();
        }
    }

    //    ----------= START getMBCAmount() =----------
    
    func getMBCAmount(vin: VInType, vout: [ScriptObj]) -> Double {
        var mbcAmount: Double = 0
        
        switch vin {
        case .coinbaseTx( _):
            break
        case .scriptObj(let vin):
            for scriptObj in vin {
                for address in scriptObj.scriptPubKey.addresses {
                    if address == currentAddress {
                        mbcAmount -= Double(scriptObj.value)
                    }
                }
            }
        }
        
        for scriptObj in vout {
            for address in scriptObj.scriptPubKey.addresses {
                if address == currentAddress {
                    mbcAmount += Double(scriptObj.value)
                }
            }
        }
        
        txNumParsed += 1
        return mbcAmount
    }
    
    //    ----------= START clearData() =----------
    
    func clearData() {
        balanceLoaded = false
        txNumParsed = 0
        addresses = []
        transactionsHashes = []
        transactions = []
    }
    
}

