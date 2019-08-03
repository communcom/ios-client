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
    @IBOutlet weak var searchBar: UISearchBar!
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
        setUpSegmentio()
    }
    
    func setUpSegmentio() {
        // Segmentio
        segmentio.setup(
            content: [
                SegmentioItem(
                    title: "My communities".localized(),
                    image: nil),
                SegmentioItem(
                    title: "Discover".localized(),
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
}
