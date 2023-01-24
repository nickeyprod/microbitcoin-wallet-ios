//
//  WalletView.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 24.03.2021.
//

import SwiftUI

struct WalletView: View {
    
    @EnvironmentObject var wallet: Wallet
    @State var exit = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor(red: 0.08, green: 0.11, blue: 0.55, alpha: 1.00))
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center, spacing: 0.0) {
                    
                    // Display wallet balance and net type
                    BalanceView(wallet: wallet)
                    if (wallet.txNumParsed != wallet.transactionsHashes.count) {
                        Text("Processing transactions: \(wallet.txNumParsed) out of \(wallet.transactionsHashes.count)")
                            .padding(.top, 0).padding(.bottom, 15)
                            .foregroundColor(.white)
                            
                    }
                    
                    // Show current address
                    HStack {
                        Text(wallet.currentAddress)
                        Spacer()
                    }.font(Font.custom("Montserrat-Regular",  size: 18))
                    .padding(12.0).background(Color(red: 0.19, green: 0.15, blue: 0.80))
                    .foregroundColor(Color(.white))
                    
                    
                    
                    // Show all transactions for the addresses
                    ScrollView {
                        VStack(spacing: 1.0)  {
                            TxView(wallet: wallet)
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 30.0)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.21, green: 0.18, blue: 0.87))
                
            }.padding(0.0).edgesIgnoringSafeArea(.all)
        }
        
        .onAppear(perform: {
            let masterAddress = CryptoHelpers.getMBCAddress(from: wallet.masterPublicKey)
            wallet.addNewAddress(address: masterAddress)
            wallet.getAddressBalance()
            wallet.getAddressTransactions()
        })
        .onDisappear(perform: {
            wallet.clearData()
        })
        
        NavigationLink(destination: LoginView(), isActive: $exit) {
            EmptyView()
        }
        
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("EXIT") {
                    exit = true
                }
            }

        }
    }

}



struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}






//if tx.vin != nil {
//    Image("check-mark").resizable().frame(width: 30, height: 30).padding(.leading, 15)
//    Text("Received").padding(.vertical, 15.0).padding(.leading, 7)
//    Spacer()
//    VStack {
//        Text(String(tx.vin!) + " MBC").padding([.top, .leading, .trailing], 26.0)
//        Text(tx.date).font(Font.custom("Montserrat-Light",  size: 15))
//            .padding(.leading, 40.0)
//            .padding(.bottom, 8.0)
//            .padding(.top, 1.0)
//    }
//} else if tx.vout != nil {
//    Image(/*@START_MENU_TOKEN@*/"check-mark"/*@END_MENU_TOKEN@*/).resizable().frame(width: 30, height: 30).padding(.leading, 15)
//    Text("Send").padding(.vertical, 15.0).padding(.leading, 7)
//    Spacer()
//    VStack {
//        Text(String(tx.vout!) + " MBC").padding([.top, .leading, .trailing], 26.0)
//        Text(tx.date).font(Font.custom("Montserrat-Light",  size: 15))
//            .padding(.bottom, 8.0)
//            .padding(.leading, 40.0)
//            .padding(.top, 1.0)
//    }
//
//} else {
//    Text("...").padding()
//}
