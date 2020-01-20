//
//  Transaction.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 17.01.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

public enum TransactionType: Int {
    case send
    case convert
    case history
}

public enum TypeOfAction: String {
    case transfer = "transfer"
    case convert = "convert"
    case hold = "hold"
    case reward = "reward"
    case unhold = "unhold"
}

struct Transaction {
    // MARK: - Properties
    var recipient = Recipient()

    var operationDate: Date = Date()
    var accuracy: Int = 4
    var symbol: String = Config.defaultSymbol
    var type: TransactionType = .send
    var actionType: TypeOfAction = .transfer
    
    var amount: CGFloat = 0.0 {
        didSet {
            self.accuracy = amount == 0 ? 0 : (amount >= 1_000.0 ? 2 : 4)
        }
    }
        
    
    // MARK: - Custom Functions
    mutating func update(recipient: ResponseAPIContentGetSubscriptionsUser) {
        self.recipient.id = recipient.userId
        self.recipient.name = recipient.username
        self.recipient.avatarURL = recipient.avatarUrl
    }
}
