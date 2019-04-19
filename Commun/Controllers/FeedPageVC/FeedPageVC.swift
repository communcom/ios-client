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
    
    var cells: [UITableViewCell] = []
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = FeedPageViewModel()
        
        navigationController?.navigationBar.barTintColor = .white
        
        tableView.register(UINib(nibName: "SortingWidgetCell", bundle: nil), forCellReuseIdentifier: "SortingWidgetCell")
        tableView.register(UINib(nibName: "PostCardCell", bundle: nil), forCellReuseIdentifier: "PostCardCell")
        tableView.register(UINib(nibName: "PostCardMediaCell", bundle: nil), forCellReuseIdentifier: "PostCardMediaCell")
        tableView.register(UINib(nibName: "EditorWidgetCell", bundle: nil), forCellReuseIdentifier: "EditorWidgetCell")
        
        let searchBar = UISearchBar(frame: self.view.bounds)
        searchBar.placeholder = "Search"
        self.navigationItem.titleView = searchBar
        
        let searchField: UITextField = searchBar.value(forKey: "searchField") as! UITextField
        searchField.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9803921569, alpha: 1)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.tableFooterView = UIView()
        
        segmentioView.setup(content: [SegmentioItem(title: "All", image: nil), SegmentioItem(title: "My Feed", image: nil)],
                            style: SegmentioStyle.onlyLabel,
                            options: SegmentioOptions.default)
        
        segmentioView.selectedSegmentioIndex = 0
        
        makeSubscriptions()
    }

}
