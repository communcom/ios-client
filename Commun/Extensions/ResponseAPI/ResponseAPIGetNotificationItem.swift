//
//  ResponseAPIGetNotificationItem.swift
//  Commun
//
//  Created by Chung Tran on 2/6/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension ResponseAPIGetNotificationItem {
    // FIXME: - Restrict notification types, remove later
    static var supportedTypes: [String] = ["subscribe", "reply", "mention", "upvote", "reward", "transfer"]
    
    var attributedContent: NSAttributedString {
        let aStr = NSMutableAttributedString()
        switch eventType {
        case "mention":
            aStr.semibold(author?.username ?? "a user".localized().uppercaseFirst)
                .normal(" ")
                .normal("mentioned you in a \(entityType ?? "comment")".localized())
                .normal(": \"")
                .normal(comment?.shortText ?? "")
                .normal("\"")
            
        case "subscribe":
            aStr.semibold(user?.username ?? "a user".localized().uppercaseFirst)
                .normal(" ")
                .normal("is following you")
        
        case "upvote":
            aStr.semibold(voter?.username ?? "a user".localized().uppercaseFirst)
                .normal(" ")
                .normal("liked".localized() + " " + "your \(entityType ?? "post")".localized())
                .normal(": \"")
                .normal((comment?.shortText ?? post?.shortText ?? "") + "...\"")
            
        case "reply":
            aStr.semibold(author?.username ?? "a user".localized().uppercaseFirst)
                .normal(" ")
                .normal("left a comment".localized())
                .normal(": \"")
                .normal((comment?.shortText ?? "") + "...\"")
            
        case "reward":
            aStr.normal("you got".localized().uppercaseFirst)
                .normal(" ")
                .normal("\(amount ?? "0") \(community?.communityId ?? "POINTS")")
                .normal(" ")
                .normal("as a reward".localized())
            
        case "transfer":
            if from?.username == nil {
                aStr.normal("You received")
                    .normal(" ")
                    .normal("\(amount ?? "0") \(community?.communityId ?? "points")")
            } else if from?.username?.lowercased() != "bounty" {
                aStr.semibold(from?.username ?? "a user".localized().uppercaseFirst)
                    .normal(" ")
                    .normal("sent you".localized())
                    .normal(" ")
                    .text("\(amount ?? "0") \(pointType ?? "points")", weight: .medium, color: .appMainColor)
            } else {
                aStr.normal("you got a".localized().uppercaseFirst)
                    .normal(" ")
                    .text("\(amount ?? "0") \(pointType ?? "points")", weight: .medium, color: .appMainColor)
                    .normal(" ")
                    .normal("bounty")
            }
        default:
            aStr.normal("you got a new notification".localized().uppercaseFirst)
        }
        return aStr
    }
    
    var content: String {
        attributedContent.string
    }
}
