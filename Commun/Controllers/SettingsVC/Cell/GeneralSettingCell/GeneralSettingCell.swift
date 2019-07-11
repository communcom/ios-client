//
//  GeneralSettingCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

struct GeneralSetting {
    var name: String
    var value: String
}

class GeneralSettingCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var settingNameLabel: UILabel!
    @IBOutlet weak var settingValueLabel: UILabel!
    
    
    // MARK: - Class Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        accessoryType = .disclosureIndicator
    }
    

    // MARK: - Class Functions
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: - Custom Functions
    func setupCell(setting: GeneralSetting) {
        settingNameLabel.text = setting.name
        settingValueLabel.text = setting.value
    }
}
