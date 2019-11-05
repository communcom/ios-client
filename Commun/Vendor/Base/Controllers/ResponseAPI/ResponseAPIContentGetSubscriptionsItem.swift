//
//  ResponseAPIContentGetSubscriptionsItem.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

extension ResponseAPIContentGetSubscriptionsItem: Equatable, IdentifiableType {
    public static func == (lhs: ResponseAPIContentGetSubscriptionsItem, rhs: ResponseAPIContentGetSubscriptionsItem) -> Bool {
        switch (lhs, rhs) {
        case (.user(let user1), .user(let user2)):
            return user1 == user2
        case (.community(let community1), .community(let community2)):
            return community1 == community2
        default:
            return false
        }
    }
    
    public var identity: String {
        switch self {
        case .user(let user):
            return user.identity
        case .community(let community):
            return community.identity
        }
    }
}

extension ResponseAPIContentGetSubscriptionsUser: Equatable, IdentifiableType {
    public static func == (lhs: ResponseAPIContentGetSubscriptionsUser, rhs: ResponseAPIContentGetSubscriptionsUser) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    public var identity: String {
        return userId + "/" + username
    }
}

extension ResponseAPIContentGetSubscriptionsCommunity: Equatable, IdentifiableType {
    public static func == (lhs: ResponseAPIContentGetSubscriptionsCommunity, rhs: ResponseAPIContentGetSubscriptionsCommunity) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    public var identity: String {
        return communityId + "/" + name
    }
}
