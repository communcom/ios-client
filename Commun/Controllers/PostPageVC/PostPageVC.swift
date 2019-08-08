//
//  PostPageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

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
    @IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    
    var expandedIndexes = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup views
        viewModel.loadPost()
        viewModel.fetchNext()
        
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        
        tableView.register(UINib(nibName: "EmptyCell", bundle: nil), forCellReuseIdentifier: "EmptyCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        
        comunityNameLabel.text = viewModel.postForRequest?.community.name
        
        // action for labels
        let tap = UITapGestureRecognizer(target: self, action: #selector(userNameTapped(_:)))
        byUserLabel.isUserInteractionEnabled = true
        byUserLabel.addGestureRecognizer(tap)
        
        // dismiss keyboard when dragging
        tableView.keyboardDismissMode = .onDrag
        
        // observe post deleted
        observePostDeleted()
        
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
}

