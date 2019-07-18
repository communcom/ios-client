//
//  PasswordCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class SettingsKeyCell: UITableViewCell {
    
    @IBOutlet weak var keyTypeLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    
    func setUpWithKeyType(_ keyType: String, value: String) {
        keyTypeLabel.text = keyType.localized()
        keyLabel.text = value
    }
    
    @IBAction func copyKeyDidTouch(_ sender: Any) {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = keyLabel.text
    }
    
}
