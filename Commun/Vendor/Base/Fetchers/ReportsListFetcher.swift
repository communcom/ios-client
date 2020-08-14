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
            .do(onSuccess: {if $0.reportsCount != nil { self.reportsCount = $0.reportsCount! }})
            .map {$0.items}
    }
    
    override func handleNewData(_ items: [ResponseAPIContentGetReport]) {
        super.handleNewData(items)
        loadReports(for: items)
    }
    
    func loadReports(for items: [ResponseAPIContentGetReport]) {
        for report in items {
            guard let userId = report.post?.contentId.userId ?? report.comment?.contentId.userId,
                let communityId = report.post?.contentId.communityId ?? report.comment?.contentId.communityId,
                let permlink = report.post?.contentId.permlink ?? report.comment?.contentId.permlink
            else {return}
            RestAPIManager.instance.getEntityReports(userId: userId, communityId: communityId, permlink: permlink, limit: 3, offset: 0)
                .map {$0.items}
                .subscribe(onSuccess: {items in
                    var report = report
                    if report.type == "post" {
                        report.post?.reports?.items = items
                        report.notifyChanged()
                    }
                    if report.type == "comment" {
                        report.comment?.reports?.items = items
                        report.notifyChanged()
                    }
                })
                .disposed(by: disposeBag)
        }
    }
}
