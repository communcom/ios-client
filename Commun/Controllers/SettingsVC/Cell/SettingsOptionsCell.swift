//
//  SettingsOptionsCell.swift
//  Commun
//
//  Created by Chung Tran on 18/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

class SettingsOptionsCell: UITableViewCell {
    enum Option {
        case language(language: Language)
        case NSFWcontent(value: String)
    }
    
    @IBOutlet weak var optionNameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    func setUpWithOption(_ option: Option) {
        switch option {
        case .language(let language):
            // Supported ru and en
            optionNameLabel.text = "Interface language".localized()
            valueLabel.text = language.name
        case .NSFWcontent(_):
            optionNameLabel.text = "NSFW content".localized()
            valueLabel.text = "Always alert".localized()
        }
    }

}
