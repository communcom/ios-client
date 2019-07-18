//
//  SettingsSwitcherCell.swift
//  Commun
//
//  Created by Chung Tran on 18/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift

class SettingsSwitcherCell: UITableViewCell {
    typealias SwitcherType = (key: String, value: Bool)
    
    @IBOutlet weak var switcherImageView: UIImageView!
    @IBOutlet weak var switcherNameLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!
    
    private var bag = DisposeBag()
    
    func setUpWithType(_ type: SwitcherType) {
        // Setting
        switcherImageView.image = UIImage(named: type.key)
        switcherNameLabel.text = type.key
        switcher.isOn = type.value
    }
    
}
