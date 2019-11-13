//
//  BlacklistFetcher.swift
//  Commun
//
//  Created by Chung Tran on 11/13/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class BlacklistFetcher: ListFetcher<ResponseAPIContentGetBlacklistItem> {
    var type: GetBlacklistType
    
    init(type: GetBlacklistType) {
        self.type = type
    }
    
    override var request: Single<[ResponseAPIContentGetBlacklistItem]> {
        return RestAPIManager.instance.getBlacklist(type: type, offset: Int(offset), limit: Int(limit))
            .map {$0.items}
    }
}
