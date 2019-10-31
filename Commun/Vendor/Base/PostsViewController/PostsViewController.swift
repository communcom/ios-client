//
//  PostsViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import DZNEmptyDataSet

class PostsViewController: ListViewController<ResponseAPIContentGetPost> {
    override func setUp() {
        super.setUp()
        // setup viewmodel
        setUpViewModel()
        
        // setup datasource
        tableView.register(BasicPostCell.self, forCellReuseIdentifier: "BasicPostCell")
        tableView.register(ArticlePostCell.self, forCellReuseIdentifier: "ArticlePostCell")
        
        dataSource = MyRxTableViewSectionedAnimatedDataSource<ListSection>(
            configureCell: { dataSource, tableView, indexPath, post in
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
        )
    }
    
    func setUpViewModel() {
        viewModel = PostsViewModel()
    }
    
    override func bind() {
        super.bind()
        
        tableView.rx.modelSelected(ResponseAPIContentGetPost.self)
            .subscribe(onNext: {post in
                let postPageVC = controllerContainer.resolve(PostPageVC.self)!
                (postPageVC.viewModel as! PostPageViewModel).postForRequest = post
                self.show(postPageVC, sender: nil)
            })
            .disposed(by: disposeBag)
        
        // filter
        (viewModel as! PostsViewModel).filter
            .subscribe(onNext: {[weak self] filter in
                self?.filterChanged(filter: filter)
            })
            .disposed(by: disposeBag)
    }
    
    override func handleLoading() {
        tableView.addPostLoadingFooterView()
    }
    
    func filterChanged(filter: PostsListFetcher.Filter) {
        
    }
}
