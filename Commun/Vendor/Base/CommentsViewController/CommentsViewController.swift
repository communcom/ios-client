//
//  CommentsViewController.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class CommentsViewController: ListViewController<ResponseAPIContentGetComment>, CommentCellDelegate {
    // MARK: - Properties
    lazy var expandedComments = [ResponseAPIContentGetComment]()
    
    // MARK: Initializers
    convenience init(filter: CommentsListFetcher.Filter) {
        self.init(nibName: nil, bundle: nil)
        viewModel = CommentsViewModel(filter: filter)
    }
    
    override func setUp() {
        super.setUp()
        // setup datasource
        tableView.separatorStyle = .none
        
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
        dataSource = MyRxTableViewSectionedAnimatedDataSource<ListSection>(
            configureCell: { dataSource, tableView, indexPath, comment in
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
                cell.expanded = self.expandedComments.contains(where: {$0.identity == comment.identity})
                cell.setUp(with: comment)
                cell.delegate = self
                
                if indexPath.row == self.viewModel.items.value.count - 2 {
                    self.viewModel.fetchNext()
                }
                
                return cell
            }
        )
    }
    
    override func bind() {
        super.bind()
        
        tableView.rx.modelSelected(ResponseAPIContentGetComment.self)
            .subscribe(onNext: {post in
                #warning("Comment selected")
            })
            .disposed(by: disposeBag)
        
        // filter
        (viewModel as! CommentsViewModel).filter
            .subscribe(onNext: {[weak self] filter in
                self?.filterChanged(filter: filter)
            })
            .disposed(by: disposeBag)
        
        // forward delegate
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func bindItems() {
        viewModel.items
            .map {$0.map {ListSection(model: $0.identity, items: [$0])}}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func filterChanged(filter: CommentsListFetcher.Filter) {
        
    }
    
    override func showLoadingFooter() {
        tableView.addLoadingFooterView(
            rowType:        PlaceholderNotificationCell.self,
            tag:            notificationsLoadingFooterViewTag,
            rowHeight:      88,
            numberOfRows:   1
        )
    }
    
    override func handleListEmpty() {
        let title = "no comments"
        let description = "comments not found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
}
