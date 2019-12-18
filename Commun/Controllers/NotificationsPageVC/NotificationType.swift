//
//  NotificationType.swift
//  Commun
//
//  Created by Chung Tran on 12/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

typealias NotificationTypeDetail = (text: NSAttributedString?, icon: UIImage?)

enum NotificationType: String {
    case upvote = "upvote"
    case downvote = "downvote"
    case subscribe = "subscribe"
    case transfer = "transfer"
    case reply = "reply"
    case mention = "mention"
    case reward = "reward"
    case curatorReward = "curatorReward"
    case witnessVote = "witnessVote"
    case witnessCancelVote = "witnessCancelVote"
    
    func getDetail(from notification: ResponseAPIOnlineNotificationData) -> NotificationTypeDetail {
        var detail = NotificationTypeDetail(text: nil, icon: nil)
        let name = notification.actor?.username ?? notification.actor?.userId ?? "Unknown"
        switch self {
        case .upvote:
            let text = NSMutableAttributedString()
                .semibold(name)
                .normal(" ")
                .normal("upvoted you in a post".localized())
                .normal(": ")
                .semibold(notification.post!.title ?? "")
            
            detail.text = text
            detail.icon = UIImage(named: "NotificationUpvote")
        case .downvote:
            let text = NSMutableAttributedString()
                .semibold(name)
                .normal(" ")
                .normal("downvoted you in a post".localized())
                .normal(": ")
                .semibold(notification.post!.title ?? "")
            
            detail.text = text
            detail.icon = UIImage(named: "NotificationDownvote")
        case .subscribe:
            let text = NSMutableAttributedString()
                .semibold(name)
                .normal(" ")
                .normal("subscribed you".localized())
            detail.text = text
            detail.icon = UIImage(named: "NotificationSubscribe")
        case .transfer:
            let text = NSMutableAttributedString()
                .semibold(name)
                .normal(" ")
                .normal("transfered you".localized())
                .normal(" \(notification.value!.amount) \(notification.value!.currency)")
            detail.text = text
            detail.icon = UIImage(named: "NotificationTransfer")
        case .reply:
            let text = NSMutableAttributedString()
                .semibold(name)
            
            if let comment = notification.comment {
                text.normal(" ")
                    .normal("replied to your comment".localized())
                    .normal(": ")
                    .semibold(comment.body)
            } else if let post = notification.post {
                text.normal(" ")
                    .normal("commented on a post".localized())
                    .normal(": ")
                    .semibold(post.title ?? "")
            }
            
            detail.text = text
            detail.icon = UIImage(named: "NotificationComment")
        case .mention:
            let text = NSMutableAttributedString()
                .semibold(name)
                .normal(" ")
                .normal("mentioned you".localized())
            
            if let post = notification.post {
                text.normal(" ")
                    .normal("in a post".localized())
                    .normal(": ")
                    .semibold(post.title ?? "")
            }
            
            if let comment = notification.comment {
                text.normal(" ")
                    .normal("in a comment".localized())
                    .normal(": ")
                    .semibold(comment.body)
            }
            
            detail.text = text
            detail.icon = UIImage(named: "NotificationMention")
        case .reward:
            let text = NSMutableAttributedString()
                .semibold("+\(notification.value!.amount) \(notification.value!.currency). ")
                .normal("reward for post".localized().uppercaseFirst)
                .normal(": ")
                .semibold(notification.post!.title ?? "")
            detail.text = text
            detail.icon = UIImage(named: "NotificationRewardsForPost")
        case .curatorReward:
            let text = NSMutableAttributedString()
                .semibold("+\(notification.value!.amount) \(notification.value!.currency). ")
                .normal("reward for votes".localized().uppercaseFirst)
                .normal(": ")
                .semibold(notification.post!.title ?? "")
            detail.text = text
            detail.icon = UIImage(named: "NotificationRewardsForVotes")
        case .witnessVote:
            let text = NSMutableAttributedString()
                .semibold(name)
                .normal(" ")
                .normal("voted for you as a delegate".localized())
                .normal(". 🔥")
            detail.text = text
            detail.icon = UIImage(named: "NotificationUpvote")
        case .witnessCancelVote:
            let text = NSMutableAttributedString()
                .semibold(name)
                .normal(" ")
                .normal("has removed your voice from your...".localized())
                .normal(". 🙈")
            detail.text = text
            detail.icon = UIImage(named: "NotificationDownvote")
        }
        return detail
    }
}
