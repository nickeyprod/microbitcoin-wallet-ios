//
//  RestoreMnemonicView.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 23.06.2021.
//

import SwiftUI

struct RestoreMnemonicView: View {
    
    @State private var passPhrase: String = "Enter your full passphrase with spaces between words"
    private var placeholderText = "Enter your full passphrase with spaces between words"
    @State private var showAfrerRestoring = false
    
    @EnvironmentObject var wallet: Wallet
    
    var body: some View {
        ZStack {
            Color(UIColor(red: 0.08, green: 0.11, blue: 0.55, alpha: 1.00))
                .edgesIgnoringSafeArea(.all)
            VStack {
                MicroBitcoinLabelView()
                Spacer()
                Label("Restoring with passphrase:", systemImage: "")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                TextEditor(text: $passPhrase)
                    
                    .onTapGesture {
                    if self.passPhrase == placeholderText {
                      self.passPhrase = ""
                    }
                }.frame(maxHeight: 350).padding(10)
                Spacer()
                
                NavigationLink(destination: WalletView(), isActive: $showAfrerRestoring) {
                    EmptyView()
                }
                
                
                Button("Restore wallet") {
                    wallet.restoreWalletByMnemonic(mnemonic: passPhrase)
                    let masterAddress = CryptoHelpers.getMBCAddress(from: wallet.masterPublicKey)
                    wallet.addNewAddress(address: masterAddress)
                    showAfrerRestoring = true
                }.frame(minWidth: 0, maxWidth: 200)
                .padding(10)
                .foregroundColor(.white)
                .background(Color(red: 0.21, green: 0.18, blue: 0.87))
                .cornerRadius(6)
                .font(.title2)
                Spacer()
            }.padding()
        }
    }
}

struct RestoreMnemonicView_Previews: PreviewProvider {
    static var previews: some View {
        RestoreMnemonicView()
    }
}
