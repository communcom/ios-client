//
//  CommunitiesVC.swift
//  Commun
//
//  Created by Chung Tran on 8/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class CommunitiesVC: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentio: Segmentio!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        
        bindUI()
    }
    
    func setUp() {
        // Segmentio
        segmentio.setup(
            content: [
                SegmentioItem(title: "My communities".localized(), image: nil),
                SegmentioItem(title: "Discover".localized(), image: nil)
            ],
            style: .onlyLabel,
            options: .default)
    }
    
    func bindUI() {
        
    }

}
