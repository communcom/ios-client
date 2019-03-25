//
//  PostPageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class PostPageVC: UIViewController {

    var viewModel: PostPageViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var comunityNameLabel: UILabel!
    
    let disposeBag = DisposeBag()
    var cells: [UITableViewCell] = []
    var commentCells: [UITableViewCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.loadPost()
        viewModel.loadComments()
        
        tableView.register(UINib(nibName: "VotesCell", bundle: nil), forCellReuseIdentifier: "VotesCell")
        tableView.register(UINib(nibName: "TextContentCell", bundle: nil), forCellReuseIdentifier: "TextContentCell")
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        tableView.register(UINib(nibName: "WriteCommentCell", bundle: nil), forCellReuseIdentifier: "WriteCommentCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        
        setupSubscriptions()
        
        comunityNameLabel.text = viewModel.postForRequest?.community.name
    }

    @IBAction func moreButtonTap(_ sender: Any) {
        showAlert(title: "TODO", message: "More menu")
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

