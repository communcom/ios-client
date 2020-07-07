//
//  NonAuthUserProfileVC.swift
//  Commun
//
//  Created by Chung Tran on 7/8/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthUserProfilePageVC: UserProfilePageVC, NonAuthVCType {
    override var authorizationRequired: Bool {false}
    
    override func blockUser() {
        showAuthVC()
    }
    
    override func unblockUser() {
        showAuthVC()
    }
}
