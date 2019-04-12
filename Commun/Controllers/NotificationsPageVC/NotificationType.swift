//
//  NotificationType.swift
//  Commun
//
//  Created by Chung Tran on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

enum NotificationType: String {
    case upvote = "upvote"
    case downvote = "downvote"
    case subscribe = "subscribe"
    case unsubscribe = "unsubscribe"
    case transfer = "transfer"
    case reply = "reply"
    case mention = "mention"
    case reward = "reward"
    case votesReward = "votesReward"
}
