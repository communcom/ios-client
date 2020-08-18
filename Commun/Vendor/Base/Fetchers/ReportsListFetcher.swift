//
//  ReportsListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class ReportsListFetcher: ListFetcher<ResponseAPIContentGetReport> {
    var communityIds = [String]()
    var reportsCount: UInt64 = 0
    var contentType: String = "post"
    var status: String = "open"
    var sortBy: SortBy = .timeDesc
    
    private var countedContentTypes = [String]()
    override var request: Single<[ResponseAPIContentGetReport]> {
        RestAPIManager.instance.getReportsList(communityIds: communityIds, contentType: contentType, status: status, sortBy: sortBy, limit: Int(limit), offset: Int(offset))
            .do(onSuccess: {
                if $0.reportsCount != nil {
                    if self.countedContentTypes.contains(self.contentType) {
                        return
                    }
                    self.reportsCount += $0.reportsCount!
                    self.countedContentTypes.append(self.contentType)
                }
            })
            .map {$0.items}
    }
}
