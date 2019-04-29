//
//  NotificationSettingCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxSwift

enum NotificationSettingType: String {
    case upvote = "Upvote"
    case downvote = "Downvote"
    case points = "Points transfer"
    case comment = "Comment and reply"
    case mention = "Mention"
    case rewardsPosts = "Rewards for posts"
    case rewardsVote = "Rewards for vote"
    case following = "Following"
    case repost = "Repost"
    
    func toBool() -> Bool {
        return UserDefaults.standard.bool(forKey: self.rawValue)
    }
    
    static func getNoticeOptions() -> RequestParameterAPI.NoticeOptions {
        #warning("types message, witnessVote, witnessCancelVote missing")
        return RequestParameterAPI.NoticeOptions(
            upvote: NotificationSettingType.upvote.toBool(),
            downvote: NotificationSettingType.downvote.toBool(),
            transfer: NotificationSettingType.points.toBool(),
            reply: NotificationSettingType.comment.toBool(),
            subscribe: NotificationSettingType.following.toBool(),
            unsubscribe: false,
            mention: NotificationSettingType.mention.toBool(),
            repost: NotificationSettingType.repost.toBool(),
            reward: NotificationSettingType.rewardsPosts.toBool(),
            curatorReward: NotificationSettingType.rewardsVote.toBool(),
            message: false, //NotificationSettingType.downvote.toBool(),
            witnessVote: false, //NotificationSettingType.downvote.toBool(),
            witnessCancelVote: false //NotificationSettingType.downvote.toBool(),
        )
    }
    
    static var allCases: [NotificationSettingType] {
        return [.upvote, .downvote, .points, .comment, .mention, .rewardsVote, .rewardsPosts, .following, .repost]
    }
}

protocol NotificationSettingCellDelegate: class {
    func didFailWithError(error: Error)
}

class NotificationSettingCell: UITableViewCell {
   
    @IBOutlet weak var notificationIcon: UIImageView!
    @IBOutlet weak var notificationNameLabel: UILabel!
    @IBOutlet weak var notificationEnabledSwitcher: UISwitch!
    
    private var type: NotificationSettingType?
    private var bag = DisposeBag()
    
    weak var delegate: NotificationSettingCellDelegate?
    
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
        guard let type = type else {return}
        UserDefaults.standard.set(sender.isOn, forKey: type.rawValue)
        
        let options = NotificationSettingType.getNoticeOptions()
        
        NetworkService.shared.setOptions(options: options, type: .notify)
            .subscribe(onError: {error in
                UserDefaults.standard.set(!sender.isOn, forKey: type.rawValue)
                sender.setOn(!sender.isOn, animated: true)
                self.delegate?.didFailWithError(error: error)
            })
            .disposed(by: bag)
    }
}
