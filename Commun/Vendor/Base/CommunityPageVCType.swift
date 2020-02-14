//
//  ComunityPageVCType.swift
//  Commun
//
//  Created by Chung Tran on 2/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol CommunityPageVCType: UIViewController {
    var community: ResponseAPIContentGetCommunity? {get}
}
