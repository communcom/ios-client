//
//  CommunitiesVC.swift
//  Commun
//
//  Created by Chung Tran on 8/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import Segmentio

class CommunitiesVC: UIViewController {
    // MARK: - Properties
    let viewModel   = CommunitiesViewModel()
    let bag         = DisposeBag()
    
    // HeaderView
    var searchBar: UISearchBar!
    @IBOutlet weak var segmentio: Segmentio!
    
    // TableView
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        
        bindUI()
    }
    
    // MARK: - Set up views
    func setUp() {
        setUpSearchBar()
        setUpSegmentio()
        setUpTableView()
    }
    
    func setUpSearchBar() {
        navigationController?.navigationBar.barTintColor = .white
        
        searchBar = UISearchBar(frame: .zero)
        searchBar.placeholder = "search".localized().uppercaseFirst
        navigationItem.titleView = searchBar
        
        let searchField: UITextField = searchBar.value(forKey: "searchField") as! UITextField
        searchField.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9803921569, alpha: 1)
    }
    
    func setUpSegmentio() {
        // Segmentio
        segmentio.setup(
            content: [
                SegmentioItem(
                    title: "my communities".localized().uppercaseFirst,
                    image: nil),
                SegmentioItem(
                    title: "discover".localized().uppercaseFirst,
                    image: nil)
            ],
            style: .onlyLabel,
            options: .default)
        
        segmentio.valueDidChange = {_, index in
            self.viewModel.applyFilter(joined: index == 0 ? true: false)
        }
        
        // fire first filter
        segmentio.selectedSegmentioIndex = 1
    }
    
    func setUpTableView() {
        var contentInsets = tableView.contentInset
        contentInsets.bottom = tabBarController!.tabBar.height - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        tableView.contentInset = contentInsets
    }
}
