//
//  PostPageVC.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift
import RxDataSources

class PostPageVC: CommentsViewController {
    // MARK: - Subviews
    lazy var navigationBar = PostPageNavigationBar(height: 56)
    
    // MARK: - Properties
    override var tableViewInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 56, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Initializers
    init(post: ResponseAPIContentGetPost) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = PostPageViewModel(post: post)
    }
    
    init(userId: String, permlink: String, communityId: String) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = PostPageViewModel(userId: userId, permlink: permlink, communityId: communityId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        // navigationBar
        view.addSubview(navigationBar)
        navigationBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        navigationBar.moreButton.addTarget(self, action: #selector(openMorePostActions), for: .touchUpInside)
        
        // tableView
        tableView.keyboardDismissMode = .onDrag
    }
    
    override func bind() {
        super.bind()
        observePostDeleted()
        
        // bind loading state
        
        // bind list loading state
    }
    
    func observePostDeleted() {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetPost.self)Deleted"))
            .subscribe(onNext: { (notification) in
                guard let deletedPost = notification.object as? ResponseAPIContentGetPost,
                    deletedPost.identity == (self.viewModel as! PostPageViewModel).post.value?.identity
                    else {return}
                self.showAlert(title: "deleted".localized().uppercaseFirst, message: "the post has been deleted".localized().uppercaseFirst, completion: { (_) in
                    self.back()
                })
            })
            .disposed(by: disposeBag)
    }
    
    @objc func openMorePostActions() {
        guard let headerView = self.tableView.tableHeaderView as? PostHeaderView else {return}
        headerView.openMorePostActions()
    }
    
    override func refresh() {
        (viewModel as! PostPageViewModel).reload()
    }
}
