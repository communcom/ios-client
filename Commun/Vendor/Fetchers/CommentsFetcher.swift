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
    override var request: Single<[ResponseAPIContentGetComment]>! {
        return NetworkService.shared.getUserComments()
            .do(onSuccess: { (result) in
                // assign next sequenceKey
                self.sequenceKey = result.sequenceKey
            })
            .map {$0.items ?? []}
    }
}
