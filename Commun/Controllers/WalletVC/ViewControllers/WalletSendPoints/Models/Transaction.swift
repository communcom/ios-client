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

public enum TransActionType: String {
    case buy = "buy"
    case sell = "sell"
    case send = "send"

    case hold = "hold"
    case reward = "reward"
    case unhold = "unhold"
    case convert = "convert"
    case transfer = "transfer"
}

struct Transaction {
    // MARK: - Properties
    var buyBalance: Balance?
    var sellBalance: Balance?
    var friend: Friend?
    var amount: CGFloat = 0.0
    var history: ResponseAPIWalletGetTransferHistoryItem?
    var actionType: TransActionType = .send
    var symbol: Symbol = Symbol(sell: Config.defaultSymbol, buy: Config.defaultSymbol)

    var operationDate: Date = Date() {
        didSet {
            history = nil
        }
    }

        
    // MARK: - Custom Functions
    mutating func createFriend(from user: ResponseAPIContentGetSubscriptionsUser) {
        self.friend = (id: user.userId, name: user.username, avatarURL: user.avatarUrl)
    }
}
