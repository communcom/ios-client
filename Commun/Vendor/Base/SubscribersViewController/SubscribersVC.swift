//
//  SubscribersVC.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class SubscribersVC: ListViewController<ResponseAPIContentResolveProfile> {
    override var tableViewInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
    
    init(userId: String?, communityId: String?) {
        super.init(nibName: nil, bundle: nil)
        viewModel = SubscribersViewModel(userId: userId, communityId: communityId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1)
    }
}
