//
//  CommentsViewController.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class CommentsViewController: ListViewController<ResponseAPIContentGetComment> {
    // MARK: Initializers
    init(filter: CommentsListFetcher.Filter) {
        viewModel = CommentsViewModel(filter: filter)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        // setup datasource
        tableView.separatorStyle = .none
        
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
        dataSource = MyRxTableViewSectionedAnimatedDataSource<ListSection>(
            configureCell: { dataSource, tableView, indexPath, comment in
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
                cell.expanded = self.expandedIndexes.contains(indexPath.row)
                cell.setupFromComment(comment, expanded: )
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
    }
    
    func filterChanged(filter: CommentsListFetcher.Filter) {
        
    }
}
