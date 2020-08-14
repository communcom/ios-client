//
//  ProposalsVC.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ProposalsVC: ListViewController<ResponseAPIContentGetProposal, ProposalCell> {
    convenience init(communityIds: [String]) {
        let vm = ProposalsViewModel()
        (vm.fetcher as! ProposalsListFetcher).communityIds = communityIds
        self.init(viewModel: vm)
        defer {
            viewModel.fetchNext()
        }
    }
    
    override func setUp() {
        super.setUp()
        title = "proposals".localized().uppercaseFirst
        setLeftNavBarButtonForGoingBack()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .appLightGrayColor
    }
    
    override func handleListEmpty() {
        let title = "no proposals"
        let description = "no proposals found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func modelSelected(_ item: ResponseAPIContentGetProposal) {
        if item.contentType == "post" {
            present(PostPageVC(userId: item.data?.message_id?.author, permlink: item.data?.message_id?.permlink ?? "", communityId: item.community?.communityId), animated: true, completion: nil)
        }
    }
}
