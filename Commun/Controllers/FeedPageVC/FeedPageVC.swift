//
//  FeedPageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxSwift

class FeedPageVC: UIViewController {

    var viewModel: FeedPageViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var segmentioView: Segmentio!
    @IBOutlet weak var sortByTypeButton: UIButton!
    @IBOutlet weak var sortByTimeButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = FeedPageViewModel()
        
        navigationController?.navigationBar.barTintColor = .white
        
        let searchBar = UISearchBar(frame: self.view.bounds)
        searchBar.placeholder = "Search"
        self.navigationItem.titleView = searchBar
        
        let searchField: UITextField = searchBar.value(forKey: "searchField") as! UITextField
        searchField.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9803921569, alpha: 1)
        
        // tableView
        tableView.register(UINib(nibName: "PostCardCell", bundle: nil), forCellReuseIdentifier: "PostCardCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        // Segmentio update
        segmentioView.setup(content: [SegmentioItem(title: "My Feed".localized(), image: nil), SegmentioItem(title: "Trending".localized(), image: nil)],
                            style: SegmentioStyle.onlyLabel,
                            options: SegmentioOptions.default)
        segmentioView.valueDidChange = {_, index in
            self.viewModel.feedTypeMode.accept(index == 0 ? .byUser : .community)
            
            // if feed is my feed, then sort by time
            if index == 0 {
                self.viewModel.feedType.accept(.timeDesc)
            }
        }
        
        // fire first filter
        segmentioView.selectedSegmentioIndex = 1
        
        // dismiss keyboard when dragging
        tableView.keyboardDismissMode = .onDrag
        
        // bind ui
        bindUI()
    }

    @IBAction func postButtonDidTouch(_ sender: Any) {
        let editorVC = controllerContainer.resolve(EditorPageVC.self)
        let nav = UINavigationController(rootViewController: editorVC!)
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func photoButtonDidTouch(_ sender: Any) {
        showAlert(title: "TODO", message: "Photo button")
    }
    
    @IBAction func sortByTypeButtonDidTouch(_ sender: Any) {
        var options = FeedSortMode.allCases
        
        if viewModel.feedTypeMode.value == .byUser {
            options.removeAll(where: {$0 == .popular})
        }
        
        showActionSheet(actions: options.map { mode in
            UIAlertAction(title: mode.toString(), style: .default, handler: { (_) in
                self.viewModel.feedType.accept(mode)
            })
        })

    }
    
    @IBAction func sortByTimeButtonDidTouch(_ sender: Any) {
        showActionSheet(actions: FeedTimeFrameMode.allCases.map { mode in
            UIAlertAction(title: mode.toString(), style: .default, handler: { (_) in
                self.viewModel.sortType.accept(mode)
            })
        })
    }
    
    @objc func refresh() {
        viewModel.reload()
    }
}
