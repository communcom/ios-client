//
//  PostsViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

class PostsViewController: ListViewController<ResponseAPIContentGetPost, PostCell> {
    
    init(filter: PostsListFetcher.Filter = PostsListFetcher.Filter(feedTypeMode: .new, feedType: .time)) {
        super.init(nibName: nil, bundle: nil)
        viewModel = PostsViewModel(filter: filter)
        defer {
            viewModel.fetchNext()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        // setup datasource
        tableView.separatorStyle = .none
    }
    
    override func registerCell() {
        tableView.register(BasicPostCell.self, forCellReuseIdentifier: "BasicPostCell")
        tableView.register(ArticlePostCell.self, forCellReuseIdentifier: "ArticlePostCell")
    }
    
    override func configureCell(with post: ResponseAPIContentGetPost, indexPath: IndexPath) -> UITableViewCell {
        let cell: PostCell
        switch post.document?.attributes?.type {
        case "article":
            cell = self.tableView.dequeueReusableCell(withIdentifier: "ArticlePostCell") as! ArticlePostCell
            cell.setUp(with: post)
        case "basic":
            cell = self.tableView.dequeueReusableCell(withIdentifier: "BasicPostCell") as! BasicPostCell
            cell.setUp(with: post)
        default:
            return UITableViewCell()
        }
        
        if indexPath.row >= self.viewModel.items.value.count - 5 {
            self.viewModel.fetchNext()
        }
        
        return cell
    }
    
    override func bind() {
        super.bind()
        // filter
        (viewModel as! PostsViewModel).filter
            .subscribe(onNext: {[weak self] filter in
                self?.filterChanged(filter: filter)
            })
            .disposed(by: disposeBag)
    }
    
    override func showLoadingFooter() {
        tableView.addPostLoadingFooterView()
    }
    
    override func handleListEmpty() {
        let title = "no post"
        let description = "posts not found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst, buttonLabel: "reload".localized().uppercaseFirst + "?")
        {
            self.viewModel.reload()
        }
    }
    
    func filterChanged(filter: PostsListFetcher.Filter) {
        
    }
}
