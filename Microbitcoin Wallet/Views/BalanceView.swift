//
//  BalanceView.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 26.04.2021.
//

import SwiftUI

struct BalanceView: View {
    
    @ObservedObject var wallet: Wallet;
    
    var body: some View {
        VStack(alignment: .center) {
            // Show "MICRO BITCOIN" label
            HStack {
                Text("MICRO")
                    .font(.custom("Montserrat-Light", size: 35))
                    .foregroundColor(.white)
                
                Text("BITCOIN")
                    .font(.custom("Montserrat-Bold", size: 35))
                    .foregroundColor(.white)
                
            }
            .padding(.top, 38.0)
            // Show wallet balance
            HStack {
                Text(String(wallet.balance))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.96, green: 0.78, blue: 0.20))
                    .font(Font.custom("Montserrat-Regular", size: 35))
                if wallet.balanceLoaded {
                    Text("MBC")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .font(Font.custom("Montserrat-Regular", size: 35))
                }
                
            }.padding(5.0)
            // Show net type and status
            Text("Main Net")
                .fontWeight(.light)
                .foregroundColor(.white)
            Circle()
                .frame(width: 12.0, height: 12.0)
                .foregroundColor(Color(red: 0.96, green: 0.78, blue: 0.20))
                .padding(.bottom, 15.0)
        }
    }
}
