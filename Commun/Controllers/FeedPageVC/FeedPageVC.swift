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
    @IBOutlet weak var segmentioView: Segmentio!
    @IBOutlet weak var sortByTypeButton: UIButton!
    @IBOutlet weak var sortByTimeButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = FeedPageViewModel()
        
        navigationController?.navigationBar.barTintColor = .white
        
        tableView.register(UINib(nibName: "PostCardCell", bundle: nil), forCellReuseIdentifier: "PostCardCell")
        tableView.register(UINib(nibName: "PostCardMediaCell", bundle: nil), forCellReuseIdentifier: "PostCardMediaCell")
        
        let searchBar = UISearchBar(frame: self.view.bounds)
        searchBar.placeholder = "Search"
        self.navigationItem.titleView = searchBar
        
        let searchField: UITextField = searchBar.value(forKey: "searchField") as! UITextField
        searchField.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9803921569, alpha: 1)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.tableFooterView = UIView()
        
        // Segmentio update
        segmentioView.setup(content: [SegmentioItem(title: "All", image: nil), SegmentioItem(title: "My Feed", image: nil)],
                            style: SegmentioStyle.onlyLabel,
                            options: SegmentioOptions.default)
        segmentioView.valueDidChange = {_, index in
            self.viewModel.feedTypeMode.accept(index == 0 ? .community : .byUser)
            
            // if feed is community then sort by popular
            if index == 0 {
                self.viewModel.feedType.accept(.popular)
            }
            
            // if feed is my feed, then sort by time
            if index == 1 {
                self.viewModel.feedType.accept(.time)
            }
        }
        // fire first filter
        segmentioView.selectedSegmentioIndex = 0
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
        showActionSheet(actions: [
            UIAlertAction(title: "Top", style: .default, handler: { _ in
                self.showAlert(title: "TODO", message: "FILTER")
            }),
            UIAlertAction(title: "New", style: .default, handler: { _ in
                self.showAlert(title: "TODO", message: "FILTER")
            })])

    }
    
    @IBAction func sortByTimeButtonDidTouch(_ sender: Any) {
        showActionSheet(actions: FeedTimeFrameMode.allCases.map { mode in
            UIAlertAction(title: mode.toString(), style: .default, handler: { (_) in
                self.viewModel.sortType.accept(mode)
            })
        })
    }
}
