//
//  SearchBarTestVC.swift
//  Commun
//
//  Created by Chung Tran on 6/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class SearchBarTestVC: BaseViewController {
    override func setUp() {
        super.setUp()
        let searchBar = CMSearchBar()
        view.addSubview(searchBar)
        searchBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), excludingEdge: .bottom)
    }
}
