//
//  ProfileVC.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class ProfileVC: BaseViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    override var contentScrollView: UIScrollView? {tableView}
    
    // MARK: - Subviews
    lazy var tableView: UITableView! = UITableView(forAutoLayout: ())
    var headerView: ProfileHeaderView!
    
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        // assign tableView
        view.addSubview(tableView)
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.insetsContentViewsToSafeArea = false
        
        // assign header
        headerView = ProfileHeaderView(tableView: tableView)
        headerView.coverImageView.image = UIImage(named: "ProfilePageCover")
        headerView.avatarImageView.image = UIImage(named: "ProfilePageCover")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
