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
    var reportsCount: UInt64 {commentsReportsCount + postsReportsCount}
    var contentType: String = "post"
    var status: String = "open"
    var sortBy: SortBy = .timeDesc
    
    var commentsReportsCount: UInt64 = 0
    var postsReportsCount: UInt64 = 0
    override var request: Single<[ResponseAPIContentGetReport]> {
        RestAPIManager.instance.getReportsList(communityIds: communityIds, contentType: contentType, status: status, sortBy: sortBy, limit: Int(limit), offset: Int(offset))
            .do(onSuccess: {
                guard let count = $0.reportsCount else {return}
                if self.contentType == "post" {
                    self.postsReportsCount = count
                } else if self.contentType == "comment" {
                    self.commentsReportsCount = count
                }
            })
            .map {$0.items}
    }
}
