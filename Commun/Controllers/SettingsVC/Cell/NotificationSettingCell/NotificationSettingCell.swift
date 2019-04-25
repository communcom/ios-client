//
//  NotificationSettingCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

enum NotificationSettingType: String, CaseIterable {
    case upvote = "Upvote"
    case downvote = "Downvote"
    case points = "Points transfer"
    case comment = "Comment and reply"
    case mention = "Mention"
    case rewardsPosts = "Rewards for posts"
    case rewardsVote = "Rewards for vote"
    case following = "Following"
    case repos = "Repos"
}

class NotificationSettingCell: UITableViewCell {
   
    @IBOutlet weak var notificationIcon: UIImageView!
    @IBOutlet weak var notificationNameLabel: UILabel!
    @IBOutlet weak var notificationEnabledSwitcher: UISwitch!
    
    private var type: NotificationSettingType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(withType type: NotificationSettingType) {
        
        self.type = type
        
        notificationIcon.image = UIImage(named: type.rawValue)
        notificationNameLabel.text = type.rawValue
        notificationEnabledSwitcher.isOn = UserDefaults.standard.bool(forKey: type.rawValue)
    }
    
    @IBAction func changeSwitcher(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: type?.rawValue ?? "")
    }
    
    
}
