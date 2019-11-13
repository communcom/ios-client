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
    
    // MARK: - Subviews
    override var tableView: UITableView {
        get {
            _tableView
        }
        set {
            _tableView = newValue
        }
    }
    
    lazy var _tableView: UITableView = {
        // Override tableView to fix problem with floating footer in section
        // https://stackoverflow.com/a/32517926
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.configureForAutoLayout()
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea(with: tableViewInsets)
        tableView.backgroundColor = .white
        return tableView
    }()
    
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
        
        tableView.rx.itemSelected
            .subscribe(onNext: { (indexPath) in
                guard let cell = self.tableView.cellForRow(at: indexPath) as? CommentCell,
                    var comment = cell.comment
                    else {return}
                
                // collapse expanded comment
                self.expandedComments.removeAll(where: {$0.identity == comment.identity})
                self.tableView.reloadRows(at: [indexPath], with: .fade)
                
                // collapse replies
                comment.children = []
                comment.notifyChildrenChanged()
            })
            .disposed(by: disposeBag)
        
        // filter
        (viewModel as! CommentsViewModel).filter
            .subscribe(onNext: {[weak self] filter in
                self?.filterChanged(filter: filter)
            })
            .disposed(by: disposeBag)
    }
    
    override func bindItems() {
        viewModel.items
            .map {$0.map {ListSection(model: $0.identity, items: [$0] + ($0.children ?? []))}}
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
    
    // MARK: - Actions
    func editComment(_ comment: ResponseAPIContentGetComment) {
        // for overriding
    }
    func replyToComment(_ comment: ResponseAPIContentGetComment) {
        // for overriding
    }
}
