//
//  ChangePasswordCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
    var bag = DisposeBag()
    
    func setUpWithButtonType(_ type: ButtonType) {
        self.type = type
        button.setTitle(type.title.localized(), for: .normal)
        button.setTitleColor(type.titleColor, for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    @IBAction func changePasswordButtonTap(_ sender: Any) {
        delegate?.buttonDidTap(on: self)
    }
}
