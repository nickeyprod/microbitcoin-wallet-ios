//
//  MicroBitcoinLabelView.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 22.06.2021.
//

import SwiftUI

struct MicroBitcoinLabelView: View {
    var body: some View {
        HStack {
            Text("MICRO")
                .foregroundColor(.white)
                .font(Font.custom("Montserrat-Light", size: 22))
            Text("BITCOIN")
                .foregroundColor(.white)
                .font(Font.custom("Montserrat-Bold", size: 22))
            Text("WALLET")
                .foregroundColor(.white)
                .font(Font.custom("Montserrat-Regular", size: 22))
        }
    }
}

struct MicroBitcoinLabelView_Previews: PreviewProvider {
    static var previews: some View {
        MicroBitcoinLabelView()
    }
}
