//
//  PostPageVC.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
    lazy var commentForm = CommentForm(backgroundColor: .white)
    
    // MARK: - Properties
    var scrollToTopAfterLoadingComment = false
    var commentThatNeedsScrollTo: ResponseAPIContentGetComment?
    var startContentOffsetY: CGFloat = 0.0
    
    // MARK: - Initializers
    init(post: ResponseAPIContentGetPost) {
        let viewModel = PostPageViewModel(post: post)
        super.init(viewModel: viewModel)
    }
    
    init(userId: String? = nil, username: String? = nil, permlink: String, communityId: String? = nil, communityAlias: String? = nil) {
        let viewModel = PostPageViewModel(userId: userId, username: username, permlink: permlink, communityId: communityId, communityAlias: communityAlias)
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabBarController?.tabBar.isHidden = true
        
        setTabBarHidden(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setTabBarHidden(false)
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()

        // navigationBar
        view.addSubview(navigationBar)
        navigationBar.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        navigationBar.moreButton.addTarget(self, action: #selector(openMorePostActions), for: .touchUpInside)

        // top white view
        let topView = UIView(backgroundColor: .white)
        view.addSubview(topView)
        topView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        topView.autoPinEdge(.bottom, to: .top, of: navigationBar)

        // tableView
        tableView.contentInset = UIEdgeInsets(top: 56, left: 0, bottom: 0, right: 0)
        tableView.keyboardDismissMode = .onDrag
        
        // postView
        postView.commentsCountButton.addTarget(self, action: #selector(commentsCountButtonDidTouch), for: .touchUpInside)
//        postView.sortButton.addTarget(self, action: #selector(sortButtonDidTouch), for: .touchUpInside)
        
        // comment form
        let shadowView = UIView(forAutoLayout: ())
        shadowView.addShadow(ofColor: #colorLiteral(red: 0.221, green: 0.234, blue: 0.279, alpha: 0.07), radius: CGFloat.adaptive(width: 4.0), offset: CGSize(width: 0, height: CGFloat.adaptive(height: -3.0)), opacity: 1.0)
//        shadowView.addShadow(ofColor: .shadow, radius: 4, offset: CGSize(width: 0, height: -6), opacity: 0.1)

        view.addSubview(shadowView)
        shadowView.autoPinEdge(toSuperviewSafeArea: .leading)
        shadowView.autoPinEdge(toSuperviewSafeArea: .trailing)
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: shadowView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
        
        shadowView.addSubview(commentForm)
        commentForm.autoPinEdgesToSuperviewEdges()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        commentForm.superview?.layoutIfNeeded()
        commentForm.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 24.5)
        view.bringSubviewToFront(commentForm)
        startContentOffsetY = tableView.contentOffset.y
        navigationBar.addShadow(ofColor: .shadow, radius: 16, offset: CGSize(width: 0, height: 6), opacity: 0.05)
    }
    
    override func bind() {
        super.bind()
        // bind controls
        bindControls()
        
        // bind post
        bindPost()
        
        // completion
        if scrollToTopAfterLoadingComment {
            tableView.rx.insertedItems
                .take(1)
                .subscribe(onNext: { (_) in
                    DispatchQueue.main.async {
                        // https://stackoverflow.com/a/16071589
                        self.tableView.safeScrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                })
                .disposed(by: disposeBag)
        }
//        else if let comment = commentThatNeedsScrollTo {
//            //TODO: scroll to comment
//        }

        tableView.rx.contentOffset
        .map { $0.y <= self.startContentOffsetY }
        .distinctUntilChanged()
        .subscribe(onNext: { (showShadow) in
            self.navigationBar.addShadow(ofColor: showShadow ? .clear : .shadow, radius: 20, offset: CGSize(width: 0, height: 3), opacity: 0.07)
        })
        .disposed(by: disposeBag)
        
        // observer
        observePostDeleted()
        observeCommentAdded()
        observeUserBlocked()
        observeCommunityBlocked()
    }
    
    override func filterChanged(filter: CommentsListFetcher.Filter) {
        super.filterChanged(filter: filter)
        
        // sort button
//        var title = ""
//        switch filter.sortBy {
//        case .popularity:
//            title = "interesting first".localized().uppercaseFirst
//        case .timeDesc:
//            title = "newest first".localized().uppercaseFirst
//        case .time:
//            title = "oldest first".localized().uppercaseFirst
//        }
//        postView.sortButton.setTitle(title, for: .normal)
    }
    
    override func editComment(_ comment: ResponseAPIContentGetComment) {
        guard let document = comment.document else {return}
        commentForm.setMode(.edit, comment: comment)
        commentForm.textView.parseContentBlock(document)
            .do(onSubscribe: {
                self.showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
            })
            .subscribe(onCompleted: { [weak self] in
                self?.hideHud()
            }) { [weak self] (error) in
                self?.showError(error)
            }
            .disposed(by: disposeBag)
        commentForm.textView.becomeFirstResponder()
    }
    
    override func replyToComment(_ comment: ResponseAPIContentGetComment) {
        commentForm.setMode(.reply, comment: comment)
        commentForm.textView.becomeFirstResponder()
    }
    
    override func retrySendingComment(_ comment: ResponseAPIContentGetComment) {
        guard let block = comment.document,
            let post = (self.viewModel as! PostPageViewModel).post.value
        else {return}
        
        showAlert(title: "an error has occured".localized().uppercaseFirst, message: "Do you want to retry".localized().uppercaseFirst + "?", buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 0, completion: { (index) in
            // retry
            if index == 0 {
                // retry
                switch comment.sendingState {
                case .error(let state):
                    switch state {
                    case .editing:
                        guard let communCode = post.community?.communityId
                        else {return}
                        
                        // Send request
                        BlockchainManager.instance.updateMessage(
                            originMessage: comment,
                            communCode: communCode,
                            permlink: comment.contentId.permlink,
                            block: block,
                            uploadingImage: comment.placeHolderImage?.image
                        )
                        .subscribe(onError: { [weak self] error in
                            self?.showError(error)
                        })
                        .disposed(by: self.disposeBag)
                        
                    case .adding:
                        // deleted falling comment
                        comment.notifyDeleted()
                        
                        guard let communCode = post.community?.communityId,
                            let parentAuthorId = post.author?.userId
                            else {return}
                        
                        let parentPermlink = post.contentId.permlink
                        // Send request
                        BlockchainManager.instance.createMessage(
                            isComment: true,
                            parentPost: post,
                            communCode: communCode,
                            parentAuthor: parentAuthorId,
                            parentPermlink: parentPermlink,
                            block: block,
                            uploadingImage: comment.placeHolderImage?.image
                        )
                        .subscribe(onError: { [weak self] error in
                            self?.showError(error)
                        })
                        .disposed(by: self.disposeBag)
                        
                    case .replying:
                        // deleted falling comment
                        comment.notifyDeleted()
                        
                        guard let communCode = post.community?.communityId,
                            let parentCommentAuthorId = comment.parents.comment?.userId,
                            let parentCommentPermlink = comment.parents.comment?.permlink,
                            let parentComment = (self.viewModel as! PostPageViewModel).items.value.first(where: {$0.contentId.userId == parentCommentAuthorId && $0.contentId.permlink == parentCommentPermlink})
                        else {return}
                        
                        // Send request
                        BlockchainManager.instance.createMessage(
                            isComment: true,
                            parentPost: post,
                            isReplying: true,
                            parentComment: parentComment,
                            communCode: communCode,
                            parentAuthor: parentCommentAuthorId,
                            parentPermlink: parentCommentPermlink,
                            block: block,
                            uploadingImage: comment.placeHolderImage?.image
                        )
                        .subscribe(onError: { [weak self] error in
                            self?.showError(error)
                        })
                        .disposed(by: self.disposeBag)
                    default:
                        break
                    }
                default:
                    break
                }
            }
        })
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
                    })
            ])
    }
    
    @objc func commentsCountButtonDidTouch() {
        tableView.safeScrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}
