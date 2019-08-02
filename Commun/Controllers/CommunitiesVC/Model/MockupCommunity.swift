//
//  MockupCommunity.swift
//  Commun
//
//  Created by Chung Tran on 8/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

class MockupCommunity: Equatable, IdentifiableType {
    static func == (lhs: MockupCommunity, rhs: MockupCommunity) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: UInt
    var name: String
    var icon: UIImage?
    var joined: Bool = false
    
    init(id: UInt, name: String, icon: UIImage?, joined: Bool) {
        self.id = id
        self.name = name
        self.icon = icon
        self.joined = joined
    }
    
    static var mockupData: [MockupCommunity] {
        return [
            MockupCommunity(id: 1, name: "ADME", icon: UIImage(named: "tux"), joined: false),
            MockupCommunity(id: 2, name: "Behance", icon: UIImage(named: "tux"), joined: true),
            MockupCommunity(id: 3, name: "COMMUN", icon: UIImage(named: "tux"), joined: false),
            MockupCommunity(id: 4, name: "Dribble", icon: UIImage(named: "tux"), joined: true),
            MockupCommunity(id: 5, name: "UX Journals", icon: UIImage(named: "tux"), joined: false),
            MockupCommunity(id: 6, name: "Suppermatika", icon: UIImage(named: "tux"), joined: false),
            MockupCommunity(id: 7, name: "Overwatch", icon: UIImage(named: "tux"), joined: false),
        ]
    }
    
    public var identity: UInt {
        return id
    }
}

struct CommunityFilter: Equatable, IdentifiableType, CustomStringConvertible {
    var text: String?
    var joined: Bool?
    
    var identity: String {
        return "{\n\ttext: \(String(describing: text)),\n\tjoined: \(String(describing: joined))\n}"
    }
    
    var description: String {
        return "Community filtered \(identity)"
    }
}
