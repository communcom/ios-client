//
//  ResponseAPIGetNotificationItem.swift
//  Commun
//
//  Created by Chung Tran on 2/6/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import Localize_Swift

extension ResponseAPIGetNotificationItem {
    static var supportedTypes: [String] = ["subscribe", "reply", "mention", "upvote", "reward", "transfer", "referralRegistrationBonus", "referralPurchaseBonus"]
    
    var attributedContent: NSAttributedString {
        let aStr = NSMutableAttributedString()
        switch Localize.currentLanguage() {
        case "ru-US", "ru-RU", "ru":
            switch eventType {
            case "mention":
                aStr.semibold(author?.username ?? "a user".localized().uppercaseFirst)
                    .normal(" ")
                    .normal("упомянул тебя в")
                    .normal(" ")
                    .normal("\(entityType ?? "комментарии")".localized())
                    .normal(": \"")
                    .normal(comment?.shortText ?? "")
                    .normal("\"")
            case "subscribe":
                aStr.semibold(user?.username ?? "a user".localized().uppercaseFirst)
                    .normal(" ")
                    .normal("подписался на тебя")
            case "upvote":
                aStr.semibold(voter?.username ?? "a user".localized().uppercaseFirst)
                    .normal(" ")
                    .normal("лайкнул твой ")
                    .normal("\(entityType ?? "post")".localized())
                    .normal(": \"")
                    .normal((comment?.shortText ?? post?.shortText ?? "") + "...\"")

            case "reply":
                aStr.semibold(author?.username ?? "a user".localized().uppercaseFirst)
                    .normal(" ")
                    .normal("прокомментировал")
                    .normal(": \"")
                    .normal((comment?.shortText ?? "") + "...\"")

            case "reward":
                aStr.normal("Получено")
                    .normal(" ")
                    .normal("\(amount ?? "0")")
                    .normal(" ")
                    .normal("поинтов")
                    .normal(" ")
                    .normal("\(community?.name ?? community?.communityId ?? "")")
            case "referralRegistrationBonus":
                aStr.normal("Получены реферальные бонусы за регистрацию ")
                    .text("\(referral?.username ?? "")", weight: .medium, color: .appMainColor)
                    .normal(" ")
                    .normal("\(amount ?? "0") \(community?.name ?? community?.communityId ?? "Commun")")
            case "referralPurchaseBonus":
                aStr.normal("Получено")
                    .normal(" ")
                    .normal("\(amount ?? "0") \(community?.name ?? community?.communityId ?? "Commun")")
                    .normal(". ")
                    .normal("Реферальный бонус - 5% \(percent ?? 5)% от покупки")
                    .normal(" ")
                    .text("\(referral?.username ?? "")", weight: .medium, color: .appMainColor)
            case "transfer":
                var pointType = self.pointType
                if pointType == "token" {pointType = "Commun"}

                if from?.username == nil {
                    aStr.normal("Получено")
                        .normal(" ")
                        .normal("\(amount ?? "0") \(community?.name ?? community?.communityId ?? "points")")
                } else {
                    aStr.semibold(from?.username ?? "a user".localized().uppercaseFirst)
                        .normal(" ")
                        .normal("отправил тебе")
                        .normal(" ")
                        .text("\(amount ?? "0") \(community?.name ?? pointType ?? "points")", weight: .medium, color: .appMainColor)
                }
            default:
                aStr.normal("you've got a new notification".localized().uppercaseFirst)
            }
        default:
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
                    .normal("liked".localized() + " " + "your".localized() + " " + (entityType ?? "post").localized())
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
                    .normal("\(amount ?? "0") \(community?.name ?? community?.communityId ?? "Commun")")
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
                } else {
                    aStr.normal("you've got a".localized().uppercaseFirst)
                        .normal(" ")
                        .text("\(amount ?? "0") \(community?.name ?? pointType ?? "points")", weight: .medium, color: .appMainColor)
                        .normal(" ")
                        .normal("bounty")
                }
            default:
                aStr.normal("you've got a new notification".localized().uppercaseFirst)
            }
        }
        return aStr
    }
    
    var content: String {
        attributedContent.string
    }
}
