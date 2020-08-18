//
//  ProposalsVC.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources

class ProposalsVC: ListViewController<ResponseAPIContentGetProposal, ProposalCell>, ProposalCellDelegate {
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
        
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .none, deleteAnimation: .automatic)
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
    
    override func bind() {
        super.bind()
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
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

extension ProposalsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isCellVisible(indexPath: indexPath) {
            loadItemAtIndexPath(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let proposal = itemAtIndexPath(indexPath),
            let height = proposal.height
        else {
            return UITableView.automaticDimension
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let report = itemAtIndexPath(indexPath) else {return}
        
        // cache height
        viewModel.rowHeights[report.identity] = cell.bounds.height
        
        if tableView.isCellVisible(indexPath: indexPath) {
            loadItemAtIndexPath(indexPath)
        }
    }
    
    private func loadItemAtIndexPath(_ indexPath: IndexPath) {
        guard var item = itemAtIndexPath(indexPath),
            (item.type == "banPost" && item.post == nil && item.comment == nil)
        else {return}
        if item.contentType != "comment" {
            RestAPIManager.instance.loadPost(userId: item.data?.message_id?.author, permlink: item.data!.message_id!.permlink!, communityId: item.community?.communityId
            ).subscribe(onSuccess: { (post) in
                item.post = post
                item.postLoadingError = nil
                item.notifyChanged()
            }, onError: {error in
                item.postLoadingError = error.localizedDescription
                item.notifyChanged()
            }).disposed(by: disposeBag)
        } else {
            RestAPIManager.instance.loadComment(userId: item.data?.message_id?.author ?? "", permlink: item.data!.message_id!.permlink!, communityId: item.community?.communityId ?? ""
            ).subscribe(onSuccess: { (comment) in
                item.comment = comment
                item.postLoadingError = nil
                item.notifyChanged()
            }, onError: {error in
                item.postLoadingError = error.localizedDescription
                item.notifyChanged()
            }).disposed(by: disposeBag)
        }
    }
}
