//
//  ChangePasswordCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxSwift

protocol SettingsButtonCellDelegate: class {
    func buttonDidTap(on cell: SettingsButtonCell)
}

class SettingsButtonCell: UITableViewCell {
    typealias ButtonType = (title: String, titleColor: UIColor)
    
    @IBOutlet weak var button: UIButton!
    weak var delegate: SettingsButtonCellDelegate?
    var type: ButtonType?
    let bag = DisposeBag()
    
    func setUpWithButtonType(_ type: ButtonType) {
        self.type = type
        button.setTitle(type.title.localized(), for: .normal)
        button.setTitleColor(type.titleColor, for: .normal)
    }
    
    @IBAction func changePasswordButtonTap(_ sender: Any) {
        delegate?.buttonDidTap(on: self)
    }
}
