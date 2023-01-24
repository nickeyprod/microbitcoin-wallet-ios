//
//  MnemonicView.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 22.06.2021.
//

import SwiftUI

struct MnemonicView: View {
    
    @EnvironmentObject var wallet: Wallet
    
    @State var totalHeight = CGFloat.zero
    
    var body: some View {
        ZStack {
            Color(UIColor(red: 0.08, green: 0.11, blue: 0.55, alpha: 1.00))
                .edgesIgnoringSafeArea(.all)
            VStack {
                MicroBitcoinLabelView()
                Spacer()
                Text("This is your wallet recovery phrase. Write it down carefully to a secret place, strictly in this order, and never share it with anyone.").font(.title2).foregroundColor(.white).padding().multilineTextAlignment(.center)
                Divider().background(Color.white).frame(width: 360, alignment: .center)
                VStack {
                    GeometryReader { geometry in
                        self.generateContent(in: geometry)
                    }
                }
                .frame(height: totalHeight).padding()
                
                Spacer()
                
                NavigationLink(destination: WalletView()) {
                    Text("I wrote it down")
                        .frame(minWidth: 0, maxWidth: 200)
                        .padding(10)
                        .foregroundColor(.white)
                        .background(Color(red: 0.21, green: 0.18, blue: 0.87))
                        .cornerRadius(6)
                        .font(.title2)
                }
                Spacer()
            }
        }
        .onAppear {
//            wallet.generateMnemonic()
        }
}
    
    private func generateContent(in g: GeometryProxy) -> some View {
            var width = CGFloat.zero
            var height = CGFloat.zero

            return ZStack(alignment: .topLeading) {
                ForEach(wallet.currentMnemonic, id: \.self) { word in
                    self.item(for: word)
                        .padding([.horizontal, .vertical], 4)
                        .alignmentGuide(.leading, computeValue: { d in
                            if (abs(width - d.width) > g.size.width)
                            {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if word == wallet.currentMnemonic.last! {
                                width = 0 //last item
                            } else {
                                width -= d.width
                            }
                            return result
                        })
                        .alignmentGuide(.top, computeValue: {d in
                            let result = height
                            if word == wallet.currentMnemonic.last! {
                                height = 0 // last item
                            }
                            return result
                        })
                }
            }.background(viewHeightReader($totalHeight))
        }
    
    private func item(for text: String) -> some View {
            Text(text)
                .padding(.all, 5)
                .font(.body)
                .background(Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(5)
        }

        private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
            return GeometryReader { geometry -> Color in
                let rect = geometry.frame(in: .local)
                DispatchQueue.main.async {
                    binding.wrappedValue = rect.size.height
                }
                return .clear
            }
        }
    
}

struct MnemonicView_Previews: PreviewProvider {
    static var previews: some View {
        MnemonicView()
    }
}
