//
//  CommunitiesViewController.swift
//  Commun
//
//  Created by Chung Tran on 11/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunitiesVC: SubsViewController<ResponseAPIContentGetCommunity> {
    init(type: GetCommunitiesType, userId: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        viewModel = CommunitiesViewModel(type: type, userId: userId)
        defer {self.title = "communities".localized().uppercaseFirst}
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        navigationItem.rightBarButtonItem = nil
        tableView.register(CommunityCell.self, forCellReuseIdentifier: "CommunityCell")
        
        dataSource = MyRxTableViewSectionedAnimatedDataSource<ListSection>(
            configureCell: { (dataSource, tableView, indexPath, community) -> UITableViewCell in
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityCell") as! CommunityCell
                cell.setUp(with: community)
                
                cell.roundedCorner = []
                
                if indexPath.row == 0 {
                    cell.roundedCorner.insert([.topLeft, .topRight])
                }
                
                if indexPath.row == self.viewModel.items.value.count - 1 {
                    cell.roundedCorner.insert([.bottomLeft, .bottomRight])
                }
                
                if indexPath.row >= self.viewModel.items.value.count - 5 {
                    self.viewModel.fetchNext()
                }
                
                return cell
            }
        )
    }
    
    override func bind() {
        super.bind()
        tableView.rx.modelSelected(ResponseAPIContentGetCommunity.self)
            .subscribe(onNext: { (item) in
                self.showCommunityWithCommunityId(item.communityId)
            })
            .disposed(by: disposeBag)
    }
    
    override func handleListEmpty() {
        let title = "no communities"
        let description = "no communities found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
}
