//
//  NotificationSettingsType.swift
//  Commun
//
//  Created by Chung Tran on 18/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

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
    
    static func getOptions(_ options: ResponseAPIGetOptionsNotifyShow) {
        #warning("types unsubscribe, witnessVote, witnessCancelVote missing")
        let standard = UserDefaults.standard
        
        standard.set(options.upvote, forKey: NotificationSettingType.upvote.rawValue)
        standard.set(options.downvote, forKey: NotificationSettingType.downvote.rawValue)
        standard.set(options.transfer, forKey: NotificationSettingType.points.rawValue)
        standard.set(options.reply, forKey: NotificationSettingType.comment.rawValue)
        standard.set(options.subscribe, forKey: NotificationSettingType.following.rawValue)
        standard.set(options.mention, forKey: NotificationSettingType.mention.rawValue)
        standard.set(options.repost, forKey: NotificationSettingType.repost.rawValue)
        standard.set(options.reward, forKey: NotificationSettingType.rewardsPosts.rawValue)
        standard.set(options.curatorReward, forKey: NotificationSettingType.rewardsVote.rawValue)
    }
    
    static func getNoticeOptions() -> RequestParameterAPI.NoticeOptions {
        #warning("types unsubscribe, witnessVote, witnessCancelVote missing")
        return RequestParameterAPI.NoticeOptions(upvote:                NotificationSettingType.upvote.toBool(),
                                                 downvote:              NotificationSettingType.downvote.toBool(),
                                                 transfer:              NotificationSettingType.points.toBool(),
                                                 reply:                 NotificationSettingType.comment.toBool(),
                                                 subscribe:             NotificationSettingType.following.toBool(),
                                                 unsubscribe:           false,
                                                 mention:               NotificationSettingType.mention.toBool(),
                                                 repost:                NotificationSettingType.repost.toBool(),
                                                 reward:                NotificationSettingType.rewardsPosts.toBool(),
                                                 curatorReward:         NotificationSettingType.rewardsVote.toBool(),
                                                 witnessVote:           false,
                                                 witnessCancelVote:     false
        )
    }
    
    static var allCases: [NotificationSettingType] {
        return [.upvote, .downvote, .points, .comment, .mention, .rewardsVote, .rewardsPosts, .following, .repost]
    }
}
