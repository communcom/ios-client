//
//  ReportsListVC.swift
//  Commun
//
//  Created by Chung Tran on 8/14/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ReportsListVC: ListViewController<ResponseAPIContentGetReport, ReportCell> {
    convenience init(communityIds: [String]) {
        let vm = ReportsViewModel()
        (vm.fetcher as! ReportsListFetcher).communityIds = communityIds
        self.init(viewModel: vm)
        defer {
            viewModel.fetchNext()
        }
    }
    
    override func setUp() {
        super.setUp()
        title = "reports".localized().uppercaseFirst
        setLeftNavBarButtonForGoingBack()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .appLightGrayColor
    }
    
    override func handleListEmpty() {
        let title = "no reports"
        let description = "no reports found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func modelSelected(_ item: ResponseAPIContentGetReport) {
        
    }
}
