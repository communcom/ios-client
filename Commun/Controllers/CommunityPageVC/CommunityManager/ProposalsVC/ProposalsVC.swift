//
//  ProposalsVC.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ProposalsVC: ListViewController<ResponseAPIContentGetProposal, ProposalCell> {
//    lazy var horizontalTabBar: CMHorizontalTabBar = {
//        let sc = CMHorizontalTabBar(height: 35)
//        sc.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        sc.labels = [
//            "all".localized().uppercaseFirst,
//            "ban".localized().uppercaseFirst,
////            "users".localized().uppercaseFirst
//            "updates".localized().uppercaseFirst
//        ]
//        sc.selectedIndex = 0
//        return sc
//    }()
    
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
//        showShadowWhenScrollUp = false
//
//        horizontalTabBar.selectedIndexesDidChange = {index in
//            guard let index = index.first else {return}
//            switch index {
//            case 0:
//                (self.viewModel.fetcher as! ProposalsListFetcher).action = nil
//            case 1:
//                (self.viewModel.fetcher as! ProposalsListFetcher).action = "banPost"
//            case 2:
//                (self.viewModel.fetcher as! ProposalsListFetcher).action = "setinfo"
//            default:
//                return
//            }
//            self.viewModel.reload(clearResult: true)
//        }
    }
    
//    override func viewWillSetUpTableView() {
//        super.viewWillSetUpTableView()
//        view.addSubview(horizontalTabBar.padding(UIEdgeInsets(horizontal: 0, vertical: 16)))
//        horizontalTabBar.paddingView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
//    }
//    
//    override func viewDidSetUpTableView() {
//        super.viewDidSetUpTableView()
//        tableView.removeConstraintToSuperView(withAttribute: .top)
//        horizontalTabBar.paddingView.autoPinEdge(.bottom, to: .top, of: tableView)
//    }
    
    override func handleListEmpty() {
        let title = "no proposals"
        let description = "no proposals found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func modelSelected(_ item: ResponseAPIContentGetProposal) {
        if let post = item.post {
            present(PostPageVC(post: post), animated: true, completion: nil)
            return
        }
        
        if item.type == "banPost" && item.contentType != "comment" {
            present(PostPageVC(userId: item.data?.message_id?.author, permlink: item.data?.message_id?.permlink ?? "", communityId: item.community?.communityId), animated: true, completion: nil)
            return
        }
    }
}
