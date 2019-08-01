//
//  MockupCommunity.swift
//  Commun
//
//  Created by Chung Tran on 8/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

struct MockupCommunity {
    var name: String
    var icon: UIImage?
    var joined: Bool = false
}

enum MockupCommunityFilter {
    case myCommunities
    case discover
    case search(text: String)
}
