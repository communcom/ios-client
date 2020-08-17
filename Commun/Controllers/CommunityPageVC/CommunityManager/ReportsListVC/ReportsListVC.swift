//
//  ReportsListVC.swift
//  Commun
//
//  Created by Chung Tran on 8/14/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ReportsListVC: ListViewController<ResponseAPIContentGetReport, ReportCell> {
    lazy var horizontalTabBar: CMHorizontalTabBar = {
        let sc = CMHorizontalTabBar(height: 35)
        sc.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        sc.labels = [
            "posts".localized().uppercaseFirst,
            "comments".localized().uppercaseFirst
        ]
        sc.selectedIndex = 0
        return sc
    }()
    
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
        
        showShadowWhenScrollUp = false

        horizontalTabBar.selectedIndexesDidChange = {index in
            guard let index = index.first else {return}
            switch index {
            case 0:
                (self.viewModel.fetcher as! ReportsListFetcher).contentType = "post"
            case 1:
                (self.viewModel.fetcher as! ReportsListFetcher).contentType = "comment"
            default:
                return
            }
            self.viewModel.reload(clearResult: true)
        }
    }
    
    override func bind() {
        super.bind()
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func viewWillSetUpTableView() {
        super.viewWillSetUpTableView()
        view.addSubview(horizontalTabBar.padding(UIEdgeInsets(horizontal: 0, vertical: 16)))
        horizontalTabBar.paddingView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
    }

    override func viewDidSetUpTableView() {
        super.viewDidSetUpTableView()
        tableView.removeConstraintToSuperView(withAttribute: .top)
        horizontalTabBar.paddingView.autoPinEdge(.bottom, to: .top, of: tableView)
    }
    
    override func handleListEmpty() {
        let title = "no reports"
        let description = "no reports found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func modelSelected(_ item: ResponseAPIContentGetReport) {
        if let post = item.post {
            present(PostPageVC(post: post), animated: true, completion: nil)
        }
    }
}

extension ReportsListVC: UITableViewDelegate {
    func reportAtIndexPath(_ indexPath: IndexPath) -> ResponseAPIContentGetReport? {
        viewModel.items.value[safe: indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isCellVisible(indexPath: indexPath) {
            guard let report = reportAtIndexPath(indexPath),
                let userId = report.post?.contentId.userId ?? report.comment?.contentId.userId,
                let communityId = report.post?.contentId.communityId ?? report.comment?.contentId.communityId,
                let permlink = report.post?.contentId.permlink ?? report.comment?.contentId.permlink,
                report.post?.reports?.items == nil && report.comment?.reports?.items == nil
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
        print("will display: \(indexPath.row)", tableView.isCellVisible(indexPath: indexPath))
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let report = reportAtIndexPath(indexPath),
            let height = viewModel.rowHeights[report.identity]
        else {return UITableView.automaticDimension}
        return height
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let report = reportAtIndexPath(indexPath) else {return}

        // cache height
        viewModel.rowHeights[report.identity] = cell.bounds.height
    }
}
