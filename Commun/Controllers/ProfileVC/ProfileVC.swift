//
//  ProfileVC.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class ProfileVC: BaseViewController, VCWithParallax {
    // MARK: - Constants
    // for parallax
    var headerHeight: CGFloat = 421
    var headerView: UIView!
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    override var contentScrollView: UIScrollView? {tableView}
    
    // MARK: - Subviews
    lazy var tableView: UITableView! = UITableView(forAutoLayout: ())
    
    
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
        let headerView = ProfileHeaderView(frame: .zero)
        headerView.tableView = tableView
        headerView.coverImageView.image = UIImage(named: "ProfilePageCover")
        headerView.avatarImageView.image = UIImage(named: "ProfilePageCover")
        
        let containerView = UIView(forAutoLayout: ())
        
        containerView.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges()
        
        tableView.tableHeaderView = containerView
        
        containerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        
        tableView.tableHeaderView?.layoutIfNeeded()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
