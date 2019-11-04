//
//  SubscribersVC.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class SubscribersVC: SubsViewController<ResponseAPIContentResolveProfile> {
    init(userId: String? = nil, communityId: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        viewModel = SubscribersViewModel(userId: userId, communityId: communityId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        tableView.register(SubscribersCell.self, forCellReuseIdentifier: "SubscribersCell")
        
        dataSource = MyRxTableViewSectionedAnimatedDataSource<ListSection>(
            configureCell: { dataSource, tableView, indexPath, subscriber in
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "SubscribersCell") as! SubscribersCell
                cell.setUp(with: subscriber)
                
                if indexPath.row >= self.viewModel.items.value.count - 5 {
                    self.viewModel.fetchNext()
                }
                
                return cell
            }
        )
    }
    
    override func bind() {
        super.bind()
        tableView.rx.modelSelected(ResponseAPIContentResolveProfile.self)
            .subscribe(onNext: { (item) in
                self.showProfileWithUserId(item.userId)
            })
            .disposed(by: disposeBag)
    }
    
    override func handleListEmpty() {
        let title = "no subscribers"
        let description = "no subscribers found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
}
