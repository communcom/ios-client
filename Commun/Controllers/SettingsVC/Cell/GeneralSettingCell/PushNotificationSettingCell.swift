//
//  NotificationSettingCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

class PushNotificationSettingCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var pushNotificationsLabel: UILabel!
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    
    // MARK: - Class Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    deinit {
        Logger.log(message: "Success", event: .severe)
    }
    

    // MARK: - Class Functions
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: - Custom Functions
    func setup() {
        self.pushNotificationsLabel.text     =   "Push notifications".localized()
        self.pushNotificationsSwitch.isOn    =   UserDefaults.standard.bool(forKey: "pushNotifications")
    }
    
    @IBAction func changeSwitchState(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "pushNotifications")
        
        // API `push.notifyOn` or `push.notifyOff`
        
    }
}
