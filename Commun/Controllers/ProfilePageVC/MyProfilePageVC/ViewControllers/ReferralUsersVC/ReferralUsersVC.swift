//
//  ReferralUsersVC.swift
//  Commun
//
//  Created by Chung Tran on 3/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ReferralUsersVC: SubsViewController<ResponseAPIContentGetProfile, SubscribersCell> {
    lazy var headerView = ReferralHeaderView(tableView: tableView)
    
    init() {
        let vm = ReferralUsersViewModel()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        headerView.shareButton.addTarget(self, action: #selector(shareButtonDidTouch), for: .touchUpInside)
        headerView.copyButton.addTarget(self, action: #selector(copyButtonDidTouch), for: .touchUpInside)
        headerView.learnMoreButton.addTarget(self, action: #selector(infoButtonDidTouch), for: .touchUpInside)
    }
    
    override func handleListEmpty() {
        let title = "no referral users"
        let description = "no referral users found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func configureCell(with item: ResponseAPIContentGetProfile, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(with: item, indexPath: indexPath) as! SubscribersCell
        cell.followButton.isHidden = true
        return cell
    }
    
    override func modelSelected(_ user: ResponseAPIContentGetProfile) {
        // do nothing
    }
    
    @objc func shareButtonDidTouch() {
        
    }
    
    @objc func copyButtonDidTouch() {
        
    }
    
    @objc func infoButtonDidTouch() {
        
    }
}
