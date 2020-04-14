//
//  Transaction.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 17.01.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

typealias Symbol = (sell: String, buy: String)
typealias Friend = (id: String, name: String, avatarURL: String?)
typealias Balance = (name: String, avatarURL: String?, amount: CGFloat, symbol: String)

struct Transaction {
    // MARK: - Properties
    var buyBalance: Balance?
    var sellBalance: Balance?
    var friend: Friend?
    var amount: CGFloat = 0.0
    var history: ResponseAPIWalletGetTransferHistoryItem?
    var actionType: String?
    var symbol: Symbol = Symbol(sell: Config.defaultSymbol, buy: Config.defaultSymbol)

    var operationDate: Date = Date() {
        didSet {
            history = nil
        }
    }
        
    // MARK: - Custom Functions
    mutating func createFriend(from user: ResponseAPIContentGetProfile) {
        self.friend = (id: user.userId, name: user.username, avatarURL: user.avatarUrl)
    }
}
