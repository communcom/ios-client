//
//  Balance.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 17.01.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

struct Balance {
    // MARK: - Properties
    var name: String = ""
    var avatarURL: String?
    var accuracy: Int = 4

    var amount: CGFloat = 0.0 {
        didSet {
            accuracy = amount == 0 ? 0 : (amount >= 1_000 ? 2 : 4)
        }
    }
}
