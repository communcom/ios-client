//
//  NonAuthCommunityPageVC.swift
//  Commun
//
//  Created by Chung Tran on 7/8/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthCommunityPageVC: CommunityPageVC, NonAuthVCType {
    override var authorizationRequired: Bool {false}
}
