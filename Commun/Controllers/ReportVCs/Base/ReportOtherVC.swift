//
//  ReportOtherVC.swift
//  Commun
//
//  Created by Chung Tran on 2/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ReportOtherVC: BaseViewController {
    // MARK: - Subviews
    lazy var closeButton = UIButton.close()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "please enter a reason".localized().uppercaseFirst
        navigationItem.setHidesBackButton(true, animated: false)
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
}
