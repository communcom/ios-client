//
//  FeedPageVC.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

final class FeedPageVC: PostsViewController {
    // MARK: - Properties
    lazy var floatView = FeedPageFloatView(forAutoLayout: ())
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        view.backgroundColor = #colorLiteral(red: 0.9591314197, green: 0.9661319852, blue: 0.9840201735, alpha: 1)
        
        let statusBarView = UIView(backgroundColor: .appMainColor)
        view.addSubview(statusBarView)
        statusBarView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        view.addSubview(floatView)
        floatView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        floatView.autoPinEdge(.top, to: .bottom, of: statusBarView)
        
        floatView.setUp(with: PostsListFetcher.Filter(feedTypeMode: .subscriptions, feedType: .time, sortType: .all))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
