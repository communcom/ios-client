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

class PostsFetcher: ItemsFetcher<ResponseAPIContentGetPost> {
    override var request: Single<[ResponseAPIContentGetPost]>! {
        return ResponseAPIContentGetFeedResult.observableWithMockData()
            .map {$0.result!}
//            NetworkService.shared.loadFeed(sequenceKey, withFeedType: .time, withFeedTypeMode: .byUser)
            .do(onNext: { (result) in
                // assign next sequenceKey
                self.sequenceKey = result.sequenceKey
            })
            .map {$0.items ?? []}
            .asSingle()
    }
}

class CommentsFetcher: ItemsFetcher<ResponseAPIContentGetComment> {
    override var request: Single<[ResponseAPIContentGetComment]>! {
        return Observable.just([])
            .asSingle()
    }
}
