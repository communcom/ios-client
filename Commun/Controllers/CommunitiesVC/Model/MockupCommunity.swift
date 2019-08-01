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
    
    static var mockupData: [MockupCommunity] {
        return [
            MockupCommunity(name: "ADME", icon: nil, joined: false),
            MockupCommunity(name: "Behance", icon: nil, joined: false),
            MockupCommunity(name: "COMMUN", icon: nil, joined: false),
            MockupCommunity(name: "Dribble", icon: nil, joined: false),
            MockupCommunity(name: "UX Journals", icon: nil, joined: false),
            MockupCommunity(name: "Suppermatika", icon: nil, joined: false),
            MockupCommunity(name: "Overwatch", icon: nil, joined: false),
        ]
    }
}

enum MockupCommunityFilter {
    case myCommunities
    case discover
    case search(text: String)
}
