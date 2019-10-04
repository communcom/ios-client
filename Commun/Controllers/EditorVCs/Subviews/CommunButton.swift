//
//  CommunButton.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1: 0.5
        }
    }
}
