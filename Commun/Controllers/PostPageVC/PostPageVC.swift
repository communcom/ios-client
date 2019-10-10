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

public typealias CommentSection = AnimatableSectionModel<String, ResponseAPIContentGetComment>
class PostPageVC: UIViewController, CommentCellDelegate {
    var viewModel: PostPageViewModel!
    
    var headerView: PostHeaderView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var comunityNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var byUserLabel: UILabel!
    @IBOutlet weak var communityAvatarImageView: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var commentForm: CommentForm!
    @IBOutlet weak var replyingToLabel: UILabel!
    @IBOutlet weak var replyingToLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    
    var expandedIndexes = [Int]()
    
    var dataSource: MyRxTableViewSectionedAnimatedDataSource<CommentSection>!
    
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
                commentForm.parentAuthor = viewModel.post.value?.contentId.userId
                commentForm.parentPermlink = viewModel.post.value?.contentId.permlink
                commentForm.textView.text = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup viewModel
        viewModel.loadPost()
        viewModel.fetchNext()
        
        viewModel.loadingHandler = { [weak self] in
            if self?.viewModel.fetcher.reachedTheEnd == true {return}
            self?.tableView.addLoadingFooterView(
                rowType:        PlaceholderNotificationCell.self,
                tag:            notificationsLoadingFooterViewTag,
                rowHeight:      88,
                numberOfRows:   1
            )
        }
        
        viewModel.listEndedHandler = { [weak self] in
            if self?.dataSource.isEmpty == true {
                self?.addEmptyCell()
            } else {
                self?.tableView.tableFooterView = UIView()
            }
            
        }
        
        viewModel.fetchNextErrorHandler = {[weak self] error in
            guard let strongSelf = self else {return}
            strongSelf.tableView.addListErrorFooterView(with: #selector(strongSelf.didTapTryAgain(gesture:)), on: strongSelf)
            strongSelf.tableView.reloadData()
        }
        
        // setupView
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        
        comunityNameLabel.text = viewModel.postForRequest?.community.name
        
        // action for labels
        let tap = UITapGestureRecognizer(target: self, action: #selector(userNameTapped(_:)))
        byUserLabel.isUserInteractionEnabled = true
        byUserLabel.addGestureRecognizer(tap)
        
        // dismiss keyboard when dragging
        tableView.keyboardDismissMode = .onDrag
        
        // forward delegate & datasource for header in section
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // observe post deleted
        observePostDeleted()
        
        // replyingto
        replyingComment = nil
        
        // dataSource
        dataSource = MyRxTableViewSectionedAnimatedDataSource<CommentSection>(
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
        
        // bind ui
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func observePostDeleted() {
        NotificationCenter.default.rx.notification(.init(rawValue: PostControllerPostDidDeleteNotification))
            .subscribe(onNext: { (notification) in
                guard let deletedPost = notification.object as? ResponseAPIContentGetPost,
                    deletedPost.identity == self.viewModel.post.value?.identity
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
    
    func back() {
        if (self.isModal) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController()
        }
    }
    
    @objc func userNameTapped(_ sender: UITapGestureRecognizer) {
        guard let userId = viewModel.post.value?.author?.userId else {return}
        showProfileWithUserId(userId)
    }
    @IBAction func replyingToCloseDidTouch(_ sender: Any) {
        replyingComment = nil
    }
    
    @objc func didTapTryAgain(gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
            let text = label.text else {return}
        
        let tryAgainRange = (text as NSString).range(of: "Try again".localized())
        if gesture.didTapAttributedTextInLabel(label: label, inRange: tryAgainRange) {
            self.viewModel.fetchNext()
        }
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
}

