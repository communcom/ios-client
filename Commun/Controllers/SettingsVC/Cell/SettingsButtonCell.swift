//
//  ChangePasswordCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

protocol SettingsButtonCellDelegate {
    func buttonDidTap(on cell: SettingsButtonCell)
}

class SettingsButtonCell: UITableViewCell {
    enum ButtonType {
        case changeAllPassword
        case logout
    }
    
    @IBOutlet weak var button: UIButton!
    var delegate: SettingsButtonCellDelegate?
    
    func setUpWithButtonType(_ type: ButtonType) {
        switch type {
        case .changeAllPassword:
            button.setTitle("Change all password".localized(), for: .normal)
        case .logout:
            button.setTitle("Log out".localized(), for: .normal)
        }
    }
    
    @IBAction func changePasswordButtonTap(_ sender: Any) {
        delegate?.buttonDidTap(on: self)
    }
}
