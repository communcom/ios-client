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
    
    override var request: Single<[ResponseAPIContentGetReport]> {
        RestAPIManager.instance.getReportsList(communityIds: communityIds, contentType: contentType, status: status, sortBy: sortBy, limit: Int(limit), offset: Int(offset))
            .do(onSuccess: {self.reportsCount = $0.reportsCount})
            .map {$0.items}
    }
}
