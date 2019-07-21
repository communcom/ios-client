//
//  PasswordCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class SettingsKeyCell: UITableViewCell {
    typealias KeyType = (key: String, value: String)
    
    @IBOutlet weak var keyTypeLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    
    func setUpWithKeyType(_ keyType: KeyType) {
        keyTypeLabel.text = keyType.key.localized()
        keyLabel.text = keyType.value.localized()
    }
    
    @IBAction func copyKeyDidTouch(_ sender: Any) {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = keyLabel.text
        parentViewController?.showDone("Copied to clipboard")
    }
    
}
