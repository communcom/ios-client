//
//  UserProfilePageVC.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class UserProfilePageVC: ProfileVC<ResponseAPIContentGetProfile> {
    // MARK: - Properties
    let userId: String
    lazy var viewModel = UserProfilePageViewModel(profileId: userId)
    
    // MARK: - Initializers
    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func bind() {
        super.bind()
        
        
    }
}
