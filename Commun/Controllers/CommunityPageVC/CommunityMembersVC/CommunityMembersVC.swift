//
//  CommunityMembersVC.swift
//  Commun
//
//  Created by Chung Tran on 11/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class CommunityMembersVC: BaseViewController {
    // MARK: - Properties
    var selectedIndex: Int
    let disposeBag = DisposeBag()
    
    // MARK: - Subviews
    lazy var backButton = UIButton.back(contentInsets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 24))
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
        setLeftNavBarButton(with: backButton)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        edgesForExtendedLayout = .all
        view.backgroundColor = .f3f5fa
        
        let topBarContainerView = UIView(height: 55, backgroundColor: .white)
        view.addSubview(topBarContainerView)
        topBarContainerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        
        topBarContainerView.addSubview(topTabBar)
        topTabBar.autoPinEdge(toSuperviewEdge: .leading)
        topTabBar.autoPinEdge(toSuperviewEdge: .trailing)
        topTabBar.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
}
