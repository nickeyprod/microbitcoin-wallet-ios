//
//  TxView.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 11.04.2021.
//

import SwiftUI

struct TxView: View {
    
    @ObservedObject var wallet: Wallet;
    
    var helpers = Helpers()
    
    var body: some View {
        // Transactions of the current address
        VStack(spacing: 1.0)  {
            
            ForEach(wallet.transactions, id: \.self) { tx in
                HStack {
                    Image("check-mark").resizable().frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    if tx.amount.sign == .minus {
                        Text("Sent")
                    } else {
                        Text("Received")
                    }
                    
                    Spacer()
                    Text("\(helpers.handleBalanceDisplaying(balance: tx.amount)) MBC")
                }.padding()
                .background(Color(red: 0.18, green: 0.13, blue: 0.76))
                .font(Font.custom("Montserrat-Bold",  size: 18))
            }
            
            if wallet.txNumParsed != wallet.transactionsHashes.count {
                HStack {
                    ProgressView().padding().progressViewStyle(CircularProgressViewStyle(tint: .white))
                }.frame(maxWidth: .infinity, alignment: .center)
                .background(Color(red: 0.18, green: 0.13, blue: 0.76))
            }

        }
    }
   
}


extension String {
  func trunc(length: Int, trailing: String = "…") -> String {
    return (self.count > length) ? self.prefix(length) + trailing : self
  }
}
