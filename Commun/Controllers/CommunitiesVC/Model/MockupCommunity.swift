//
//  MockupCommunity.swift
//  Commun
//
//  Created by Chung Tran on 8/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

struct MockupCommunity: Equatable, IdentifiableType {
    let id: UInt
    var name: String
    var icon: UIImage?
    var joined: Bool = false
    
    static var mockupData: [MockupCommunity] {
        return [
            MockupCommunity(id: 1, name: "ADME", icon: nil, joined: false),
            MockupCommunity(id: 2, name: "Behance", icon: nil, joined: true),
            MockupCommunity(id: 3, name: "COMMUN", icon: nil, joined: false),
            MockupCommunity(id: 4, name: "Dribble", icon: nil, joined: true),
            MockupCommunity(id: 5, name: "UX Journals", icon: nil, joined: false),
            MockupCommunity(id: 6, name: "Suppermatika", icon: nil, joined: false),
            MockupCommunity(id: 7, name: "Overwatch", icon: nil, joined: false),
        ]
    }
    
    public var identity: UInt {
        return id
    }
}

enum CommunityFilter: Equatable, IdentifiableType {
    case myCommunities
    case discover
    case search(text: String)
    
    var identity: String {
        switch self {
        case .myCommunities:
            return "My Communities"
        case .discover:
            return "Discover"
        case .search(let text):
            return "Search \(text)"
        }
    }
}
