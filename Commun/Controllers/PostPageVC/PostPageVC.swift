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
    // MARK: - Nested types
    class ReplyButton: UIButton {
        var parentComment: ResponseAPIContentGetComment?
        var offset: UInt = 0
        var limit: UInt = 10
        
    }
    
    // MARK: - Subviews
    lazy var navigationBar = PostPageNavigationBar(height: 56)
    lazy var postView = PostHeaderView(tableView: tableView)
    
    // MARK: - Properties
    
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
    
    // MARK: - Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        let tabBar = (tabBarController as? TabBarVC)?.tabBarStackView.superview
        tabBar?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        let tabBar = (tabBarController as? TabBarVC)?.tabBarStackView.superview
        tabBar?.isHidden = false
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        // navigationBar
        view.addSubview(navigationBar)
        navigationBar.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        navigationBar.moreButton.addTarget(self, action: #selector(openMorePostActions), for: .touchUpInside)
        
        // tableView
        tableView.contentInset = UIEdgeInsets(top: 56, left: 0, bottom: 0, right: 0)
        tableView.keyboardDismissMode = .onDrag
        
        // postView
        postView.sortButton.addTarget(self, action: #selector(sortButtonDidTouch), for: .touchUpInside)
    }
    
    override func bind() {
        super.bind()
        
        observePostDeleted()
        
        // bind controls
        bindControls()
        
        // bind post
        bindPost()
        
        // forward delegate
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func filterChanged(filter: CommentsListFetcher.Filter) {
        super.filterChanged(filter: filter)
        
        // sort button
        var title = ""
        switch filter.sortBy {
        case .popularity:
            title = "interesting first".localized().uppercaseFirst
        case .timeDesc:
            title = "newest first".localized().uppercaseFirst
        case .time:
            title = "oldest first".localized().uppercaseFirst
        }
        postView.sortButton.setTitle(title, for: .normal)
    }
    
    @objc func openMorePostActions() {
        postView.openMorePostActions()
    }
    
    @objc func sortButtonDidTouch() {
        showCommunActionSheet(
            title: "sort by".localized().uppercaseFirst,
            actions: [
                CommunActionSheet.Action(
                    title: "interesting first".localized().uppercaseFirst,
                    handle: {
                        let vm = self.viewModel as! CommentsViewModel
                        vm.changeFilter(sortBy: .popularity)
                    }),
                CommunActionSheet.Action(
                    title: "newest first".localized().uppercaseFirst,
                    handle: {
                        let vm = self.viewModel as! CommentsViewModel
                        vm.changeFilter(sortBy: .timeDesc)
                    }),
                CommunActionSheet.Action(
                    title: "oldest first".localized().uppercaseFirst,
                    handle: {
                        let vm = self.viewModel as! CommentsViewModel
                        vm.changeFilter(sortBy: .time)
                    }),
            ])
    }
    
    override func refresh() {
        (viewModel as! PostPageViewModel).reload()
    }
}
