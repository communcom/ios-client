//
//  ResponseAPIGetNotificationItem.swift
//  Commun
//
//  Created by Chung Tran on 2/6/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension ResponseAPIGetNotificationItem {
    static var supportedTypes: [String] = ["subscribe", "reply", "mention", "upvote", "reward", "transfer", "referralRegistrationBonus", "referralPurchaseBonus"]
    
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
            aStr.normal("you've got".localized().uppercaseFirst)
                .normal(" ")
                .normal("\(amount ?? "0") \(community?.name ?? community?.communityId ?? "")")
                .normal(" ")
                .normal("points".localized())

        case "referralRegistrationBonus":
            aStr.normal("you received".localized().uppercaseFirst)
                .normal(" ")
                .normal("a referral bonus for the registration of".localized())
                .normal(" ")
                .text("\(referral?.username ?? "")", weight: .medium, color: .appMainColor)
                .normal(" ")
                .normal("\(amount ?? "0") \(community?.name ?? community?.communityId ?? "Commun")")

        case "referralPurchaseBonus":
            aStr.normal("you received".localized().uppercaseFirst)
                .normal(" ")
                .normal("\(amount ?? "0") \(community?.name ?? community?.communityId ?? "")")
                .normal(" ")
                .normal("it's a referral bounty - \(percent ?? 5)% of".localized().uppercaseFirst)
                .normal(" ")
                .text("\(referral?.username ?? "")", weight: .medium, color: .appMainColor)
                .normal("'s purchase")

        case "transfer":
            var pointType = self.pointType
            if pointType == "token" {pointType = "Commun"}
            
            if from?.username == nil {
                aStr.normal("You received")
                    .normal(" ")
                    .normal("\(amount ?? "0") \(community?.name ?? community?.communityId ?? "points")")
            } else if from?.username?.lowercased() != "bounty" {
                aStr.semibold(from?.username ?? "a user".localized().uppercaseFirst)
                    .normal(" ")
                    .normal("sent you".localized())
                    .normal(" ")
                    .link("communwallet://\(community?.communityId ?? "CMN")", placeholder: "\(amount ?? "0") \(pointType ?? "points")", font: .systemFont(ofSize: 15, weight: .medium))
            } else {
                aStr.normal("you've got a".localized().uppercaseFirst)
                    .normal(" ")
                    .text("\(amount ?? "0") \(pointType ?? "points")", weight: .medium, color: .appMainColor)
                    .normal(" ")
                    .normal("bounty")
            }
        default:
            aStr.normal("you've got a new notification".localized().uppercaseFirst)
        }
        return aStr
    }
    
    var content: String {
        attributedContent.string
    }
}
