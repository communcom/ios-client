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
    lazy var tableView: UITableView! = UITableView()
    
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        // assign tableView
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        
        // assign header
        let headerView = ProfileHeaderView(forAutoLayout: ())
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        headerView.coverImageView.image = UIImage(named: "ProfilePageCover")
        headerView.avatarImageView.image = UIImage(named: "ProfilePageCover")
    }
}
