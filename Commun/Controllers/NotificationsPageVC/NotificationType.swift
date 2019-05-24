//
//  NotificationType.swift
//  Commun
//
//  Created by Chung Tran on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
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
    
    func getDetail(from notification: ResponseAPIOnlineNotificationData) -> NotificationTypeDetail {
        var detail = NotificationTypeDetail(text: nil, icon: nil)
        switch self {
        case .upvote:
            let text = NSMutableAttributedString()
                .bold(notification.actor!.id ?? "Unknown")
                .normal(" ")
                .normal("upvoted you in a post".localized())
                .normal(": ")
                .bold(notification.post!.title)
            
            detail.text = text
            detail.icon = UIImage(named: "NotificationUpvote")
            break
        case .downvote:
            let text = NSMutableAttributedString()
                .bold(notification.actor!.id ?? "Unknown")
                .normal(" ")
                .normal("downvoted you in a post".localized())
                .normal(": ")
                .bold(notification.post!.title)
            
            detail.text = text
            detail.icon = #imageLiteral(resourceName: "Group 116 (1).png")
            break
        case .subscribe:
            let text = NSMutableAttributedString()
                .bold(notification.actor!.id ?? "Unknown")
                .normal(" ")
                .normal("subscribed you".localized())
            detail.text = text
            detail.icon = UIImage(named: "NotificationSubscribe")
            break
        case .transfer:
            let text = NSMutableAttributedString()
                .bold(notification.actor!.id ?? "Unknown")
                .normal(" ")
                .normal("transfered you".localized())
                .normal(" \(notification.value!.amount) \(notification.value!.currency)")
            detail.text = text
            detail.icon = UIImage(named: "NotificationTransfer")
            break
        case .reply:
            let text = NSMutableAttributedString()
                .bold(notification.actor!.id ?? "Unknown")
            
            if let comment = notification.comment {
                text.normal(" ")
                    .normal("replied to your comment".localized())
                    .normal(": ")
                    .bold(comment.body)
            } else if let post = notification.post {
                text.normal(" ")
                    .normal("commented on a post".localized())
                    .normal(": ")
                    .bold(post.title)
            }
            
            detail.text = text
            detail.icon = UIImage(named: "NotificationComment")
            break
        case .mention:
            let text = NSMutableAttributedString()
                .bold(notification.actor!.id ?? "Unknown")
                .normal(" ")
                .normal("mentioned you".localized())
            
            if let post = notification.post {
                text.normal(" ")
                    .normal("in a post".localized())
                    .normal(": ")
                    .bold(post.title)
            }
            
            if let comment = notification.comment {
                text.normal(" ")
                    .normal("in a comment".localized())
                    .normal(": ")
                    .bold(comment.body)
            }
            
            detail.text = text
            detail.icon = UIImage(named: "NotificationMention")
            break
        case .reward:
            let text = NSMutableAttributedString()
                .bold("+\(notification.value!.amount) \(notification.value!.currency). ")
                .normal("Reward for post".localized())
                .normal(": ")
                .bold(notification.post!.title)
            detail.text = text
            detail.icon = UIImage(named: "NotificationRewardsForPost")
            break
        case .curatorReward:
            let text = NSMutableAttributedString()
                .bold("+\(notification.value!.amount) \(notification.value!.currency). ")
                .normal("Reward for votes".localized())
                .normal(": ")
                .bold(notification.post!.title)
            detail.text = text
            detail.icon = UIImage(named: "NotificationRewardsForVotes")
            break
        }
        return detail
    }
}
