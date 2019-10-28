//
//  PostPageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import RxDataSources

class PostPageVC: ListViewController<ResponseAPIContentGetComment>, CommentCellDelegate {
    
    var headerView: PostHeaderView!
    @IBOutlet weak var _tableView: UITableView!
    
    override var tableView: UITableView! {
        get {return _tableView}
        set {_tableView = newValue}
    }
    
    @IBOutlet weak var navigationBar: PostPageNavigationBar!
    @IBOutlet weak var commentForm: CommentForm!
    @IBOutlet weak var replyingToLabel: UILabel!
    @IBOutlet weak var replyingToLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
    
    var expandedIndexes = [Int]()
    
    var replyingComment: ResponseAPIContentGetComment? {
        didSet {
            if let comment = self.replyingComment {
                replyingToLabelHeightConstraint.constant = 16
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
                commentForm.parentAuthor = comment.contentId.userId
                commentForm.parentPermlink = comment.contentId.permlink
                replyingToLabel.text = "replying to".localized().uppercaseFirst + " " + (comment.author?.username ?? "")
                
                let mention = "@" + (comment.author?.username ?? comment.contentId.userId)
                
                var attrs = commentForm.textView.defaultTypingAttributes
                attrs[.link] = URL.appURL + "/" + mention
                
                let mentionAS = NSMutableAttributedString(string: mention, attributes: attrs)
                commentForm.textView.textStorage.insert(mentionAS, at: 0)
                commentForm.textView.insertTextWithDefaultAttributes(" ", at: mentionAS.length)
                commentForm.textView.selectedRange = NSMakeRange(commentForm.textView.textStorage.length, 0)
                commentForm.textView.becomeFirstResponder()
            } else {
                replyingToLabelHeightConstraint.constant = 0
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
                commentForm.parentAuthor = (viewModel as! PostPageViewModel).post.value?.contentId.userId
                commentForm.parentPermlink = (viewModel as! PostPageViewModel).post.value?.contentId.permlink
                commentForm.textView.text = nil
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        // navigation bar
        navigationBar.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        navigationBar.moreButton.addTarget(self, action: #selector(openMorePostActions), for: .touchUpInside)
        
        // setupView
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        
        // dismiss keyboard when dragging
        tableView.keyboardDismissMode = .onDrag
        
        // observe post deleted
        observePostDeleted()
        
        // replyingto
        replyingComment = nil
        
        // dataSource
        dataSource = MyRxTableViewSectionedAnimatedDataSource<ListSection>(
            configureCell: { dataSource, tableView, indexPath, comment in
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
                cell.setupFromComment(comment, expanded: self.expandedIndexes.contains(indexPath.row))
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
        // Observe post
        bindPost()
        
        // Observe comments
        bindComments()
        
        // Observe commentForm
        bindCommentForm()
        
        // forward delegate & datasource for header in section
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func handleLoading() {
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
    
    func observePostDeleted() {
        NotificationCenter.default.rx.notification(.init(rawValue: PostControllerPostDidDeleteNotification))
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
    
    @IBAction func backButtonTap(_ sender: Any) {
        back()
    }
    
    @objc func userNameTapped(_ sender: UITapGestureRecognizer) {
        guard let userId = (viewModel as! PostPageViewModel).post.value?.author?.userId else {return}
        showProfileWithUserId(userId)
    }
    @IBAction func replyingToCloseDidTouch(_ sender: Any) {
        replyingComment = nil
    }
    
    func addEmptyCell() {
        // init emptyView
        let emptyView = EmptyView(frame: .zero)
        
        // Prevent dupplicating
        if tableView.tableFooterView?.tag == commentEmptyFooterViewTag {
            return
        }
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.size.width, height: 214))
        containerView.tag = commentEmptyFooterViewTag
        
        containerView.addSubview(emptyView)
        
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        emptyView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        emptyView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        emptyView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
        
        tableView.tableFooterView = containerView
        emptyView.setUpEmptyComment()
    }
    
    override func refresh() {
        (viewModel as! PostPageViewModel).loadPost()
    }
    
    @objc func openMorePostActions() {
        guard let headerView = self.tableView.tableHeaderView as? PostHeaderView else {return}
        headerView.openMorePostActions()
    }
}

