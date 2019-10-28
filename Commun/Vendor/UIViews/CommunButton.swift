//
//  CommunButton.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunButton: UIButton {
    static var join: CommunButton {
        let button = CommunButton(height: 35, label: "join".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), backgroundColor: .appMainColor, textColor: .white, cornerRadius: 35 / 2, contentInsets: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        return button
    }
    
    static func `default`(label: String) -> CommunButton {
        let button = CommunButton(height: 35, label: label, labelFont: .boldSystemFont(ofSize: 15), backgroundColor: .appMainColor, textColor: .white, cornerRadius: 35 / 2, contentInsets: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        return button
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1: 0.5
        }
    }
}
