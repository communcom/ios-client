//
//  SelectLanguageVC.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class SelectLanguageVC: BaseViewController {
    // MARK: - Subviews
    let closeButton = UIButton.close()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        view.backgroundColor = .f3f5fa
        title = "language".localized().uppercaseFirst
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
