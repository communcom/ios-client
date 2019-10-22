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
    // MARK: - Enums
    struct Filter: FilterType {
        var permlink: String?
        var userId: String?
        var communityId: String?
        var communityAlias: String?
        var type: GetCommentsType
    }
    
    var filter: Filter
    
    init(filter: Filter) {
        self.filter = filter
    }
    
    override var request: Single<[ResponseAPIContentGetComment]>! {
        var result: Single<ResponseAPIContentGetComments>
        
//        #warning("mocking")
//        return ResponseAPIContentGetComments.singleWithMockData()
//            .map {$0.items!}
        
        switch filter.type {
        case .post:
            // get post's comment
            result = RestAPIManager.instance.loadPostComments(
                sortBy: .time,
                offset: offset,
                limit: 30,
                permlink: filter.permlink ?? "",
                communityId: filter.communityId,
                communityAlias: filter.communityAlias
            )
        case .user:
            result = RestAPIManager.instance.loadUserComments(
                offset: offset,
                limit: 30,
                userId: filter.userId)
        case .replies:
            fatalError("Implementing")
        }
        
        return result
            .map {$0.items ?? []}
    }
}
