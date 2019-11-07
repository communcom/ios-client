//
//  CommunityMembersVC.swift
//  Commun
//
//  Created by Chung Tran on 11/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunityMembersVC: BaseViewController {
    // MARK: - Properties
    var selectedIndex: Int
    
    // MARK: - Subviews
    lazy var topTabBar = CMTopTabBar(
        height: 35,
        labels: [
            "all".localized().uppercaseFirst,
            "leaders".localized().uppercaseFirst,
            "friends".localized().uppercaseFirst
        ],
        selectedIndex: selectedIndex)
    
    // MARK: - Initializers
    init(selectedIndex: Int) {
        self.selectedIndex = selectedIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        edgesForExtendedLayout = .all
        view.backgroundColor = .f3f5fa
        view.addSubview(topTabBar)
        topTabBar.backgroundColor = .white
        topTabBar.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
    }
}
