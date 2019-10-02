//
//  NotificationSettingsType.swift
//  Commun
//
//  Created by Chung Tran on 19/07/2019.
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
    
    static var allCases: [NotificationSettingType] {
        return [.upvote, .downvote, .points, .comment, .mention, .rewardsVote, .rewardsPosts, .following, .repost]
    }
}
