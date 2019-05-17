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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var comunityNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var byUserLabel: UILabel!
    @IBOutlet weak var communityAvatarImageView: UIImageView!
    @IBOutlet weak var commentForm: CommentForm!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup views
        viewModel.loadPost()
        viewModel.fetchNext()
        
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        
        tableView.register(UINib(nibName: "EmptyCell", bundle: nil), forCellReuseIdentifier: "EmptyCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        
        comunityNameLabel.text = viewModel.postForRequest?.community.name
        
        // dismiss keyboard when dragging
        tableView.keyboardDismissMode = .onDrag
        
        // bind ui
        bindUI()
    }

    @IBAction func moreButtonTap(_ sender: Any) {
        showAlert(title: "TODO", message: "More menu")
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

