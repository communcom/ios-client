//
//  CommunitiesViewController.swift
//  Commun
//
//  Created by Chung Tran on 11/6/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class CommunitiesVC: SubsViewController<ResponseAPIContentGetCommunity, CommunityCell>, CommunityCellDelegate {
    // MARK: - Properties
//    override var isSearchEnabled: Bool {false}
    
    // MARK: - Initializers
    init(type: GetCommunitiesType, userId: String? = nil) {
        let viewModel = CommunitiesViewModel(type: type, userId: userId)
        super.init(viewModel: viewModel)
        defer {self.title = "communities".localized().uppercaseFirst}
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        baseNavigationController?.changeStatusBarStyle(.default)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        navigationItem.rightBarButtonItem = nil
    }
    
    override func configureCell(with community: ResponseAPIContentGetCommunity, indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityCell") as! CommunityCell
        cell.setUp(with: community)
        cell.delegate = self
        
        cell.roundedCorner = []
        
        if indexPath.row == 0 {
            cell.roundedCorner.insert([.topLeft, .topRight])
        }
        
        if indexPath.row == self.viewModel.items.value.count - 1 {
            cell.roundedCorner.insert([.bottomLeft, .bottomRight])
        }
        
        return cell
    }
    
    override func handleListEmpty() {
        let title = "no communities"
        let description = "no communities found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
}
