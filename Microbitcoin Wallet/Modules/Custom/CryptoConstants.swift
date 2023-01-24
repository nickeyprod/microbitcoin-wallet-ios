//
//  CryptoConstants.swift
//  Microbitcoin Wallet
//
//  Created by Николай Ногин on 30.07.2021.
//

import Foundation

struct CryptoConstants {
    
    // Prefixes for base58check encoding function
    static let prefixes = [
        "bip32_pub": "0488b21e", // BIP32 HD wallet public key prefix (xpub)
        "bip32_prv": "0488ade4", // BIP32 HD wallet private key prefix (xprv)
        "btc_pub": "00",         // Usual bitcoin mainnet address public key prefix
        "btc_prv": "80",         // Usual bitcoin mainnet private key prefix
        "btc_tpub": "6f",        // Bitcoin testnet public key prefix
        "btc_tprv": "ef",        // Bitcoin testnet private key prefix
        "mbc_pub": "1a"          // Microbitcoin address prefix

    ]
}
