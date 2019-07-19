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

protocol SettingsSwitcherCellDelegate: class {
    func switcherDidSwitch(value: Bool, for key: String)
}

class SettingsSwitcherCell: UITableViewCell {
    typealias SwitcherType = (key: String, value: Bool, image: UIImage?)
    
    @IBOutlet weak var switcherImageView: UIImageView!
    @IBOutlet weak var switcherNameLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!
    
    private var bag = DisposeBag()
    weak var delegate: SettingsSwitcherCellDelegate?
    var key: String?
    
    func setUpWithType(_ type: SwitcherType) {
        // reassign key
        key = type.key
        
        // Setting
        switcherImageView.image = type.image ?? UIImage(named: type.key)
        switcherNameLabel.text = type.key
        switcher.isOn = type.value
    }
    
    @IBAction func switcherDidSwitch(_ sender: Any) {
        guard let key = key else {return}
        self.delegate?.switcherDidSwitch(value: self.switcher.isOn, for: key)
    }
}
