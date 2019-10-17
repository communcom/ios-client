//
//  PostsFetcher.swift
//  Commun
//
//  Created by Chung Tran on 19/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class CommentsFetcher: ItemsFetcher<ResponseAPIContentGetComment> {
    var permlink: String?
    var userId: String?
    var communityId: String?
    var communityAlias: String?
    var type: GetCommentsType
    
    init(type: GetCommentsType, userId: String? = nil, permlink: String? = nil, communityId: String? = nil, communityAlias: String? = nil) {
        self.type = type
        self.userId = userId
        self.permlink = permlink
        self.communityId = communityId
        self.communityAlias = communityAlias
    }
    
    override var request: Single<[ResponseAPIContentGetComment]>! {
        var result: Single<ResponseAPIContentGetComments>
        
        switch type {
        case .post:
            // get post's comment
            result = RestAPIManager.instance.loadPostComments(
                sortBy: .time,
                offset: offset,
                limit: 30,
                permlink: permlink ?? "",
                communityId: communityId,
                communityAlias: communityAlias
            )
        case .user:
            result = RestAPIManager.instance.loadUserComments(
                offset: offset,
                limit: 30,
                userId: userId)
        case .replies:
            fatalError("Implementing")
        }
        
        return result
            .map {$0.items ?? []}
    }
}
