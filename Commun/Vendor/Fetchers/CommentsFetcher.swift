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
    
    override var request: Single<[ResponseAPIContentGetComment]>! {
        var result: Single<ResponseAPIContentGetComments>
        if let permLink = permlink,
            let userId = userId {
            result = NetworkService.shared.getPostComment(sequenceKey, withPermLink: permLink, forUser: userId)
        } else {
            result = NetworkService.shared.getUserComments(sequenceKey)
        }
        return result
            .do(onSuccess: { (result) in
                // assign next sequenceKey
                self.sequenceKey = result.sequenceKey
            })
            .map {$0.items ?? []}
    }
}
