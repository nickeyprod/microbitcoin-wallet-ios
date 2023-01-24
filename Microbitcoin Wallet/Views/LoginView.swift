//
//  LoginView.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 01.04.2021.
//

import SwiftUI

struct LoginView: View {

    @StateObject var wallet = Wallet();
    
    @State private var showNewMnemonic = false
    @State private var restoreWithPassphrase = false
    
    var body: some View {
        VStack {
            
            NavigationView {
               
                ZStack {
                    Color(UIColor(red: 0.08, green: 0.11, blue: 0.55, alpha: 1.00))
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        Image("MBC_Logo").resizable().frame(width: 80, height: 120)
                        MicroBitcoinLabelView()
                            .padding(.vertical, 40.0)

                        NavigationLink(destination: MnemonicView(), isActive: $showNewMnemonic) {
                            EmptyView()
                        }
                        
                        NavigationLink(destination: RestoreMnemonicView(), isActive: $restoreWithPassphrase) {
                            EmptyView()
                        }
                        
                        Button {
//                            wallet.generateMnemonic()
//                            wallet.getSeedFromMnemonic()
//                            wallet.generateMasterKeys()
                            let tx = TransactionBuilder.createTransaction(spendableTxId: "165d22de87fb3ce7d8239ad7f60f38d6fb930faf17f400d96ea2634c3bc79eca", spendableOutputNum: 1, value: 9000)
//                            print(tx)
//                            TransactionBuilder.scriptPubKey2(with: "036B93AFD19584EE1B49BE70795A122A0C6E992AFB8D160EBECEFB6AB37DD2C991")
                            
                            showNewMnemonic = true
                        } label: {
                            Text("Get new wallet")
                                .frame(minWidth: 0, maxWidth: 200)
                                .padding(10)
                                .foregroundColor(.white)
                                .background(Color(red: 0.21, green: 0.18, blue: 0.87))
                                .cornerRadius(6)
                                .font(.title)
                        }.padding()
                        
                        Button {
                            restoreWithPassphrase = true
                        } label: {
                            Text("Restore wallet")
                                .frame(minWidth: 0, maxWidth: 200)
                                .padding(10)
                                .foregroundColor(.white)
                                .background(Color(red: 0.21, green: 0.18, blue: 0.87))
                                .cornerRadius(6)
                                .font(.title)
                        }

                        Spacer()
                    }
                }
                
                
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .environmentObject(wallet)
        }
        .onAppear(perform: {

        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
