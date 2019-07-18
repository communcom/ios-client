//
//  SettingsSwitcherCell.swift
//  Commun
//
//  Created by Chung Tran on 18/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class SettingsSwitcherCell: UITableViewCell {
    enum SwitcherType {
        case notification(type: NotificationSettingType)
    }
    
    @IBOutlet weak var switcherImageView: UIImageView!
    @IBOutlet weak var switcherNameLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!
    
    private var type: NotificationSettingType?
    private var bag = DisposeBag()
    
    func setUpWithType(_ type: SwitcherType) {
        // Setting
        switch type {
        case .notification(let type):
            switcherImageView.image = UIImage(named: type.rawValue)
            switcherNameLabel.text = type.rawValue
            switcher.isOn = UserDefaults.standard.bool(forKey: type.rawValue)
            
            #warning("switcher was switched")
        }
    }
    
}
