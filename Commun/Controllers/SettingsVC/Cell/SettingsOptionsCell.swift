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
    typealias Option = (key: String, value: String)
    
    @IBOutlet weak var optionNameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    func setUpWithOption(_ option: Option) {
        optionNameLabel.text = option.key
        valueLabel.text = option.value
    }

}
