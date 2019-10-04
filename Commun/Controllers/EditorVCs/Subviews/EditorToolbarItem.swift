//
//  EditorToolbarItem.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

struct EditorToolbarItem: Equatable {
    static func == (lhs: EditorToolbarItem, rhs: EditorToolbarItem) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name: String
    var icon: String
    var iconSize: CGSize
    var description: String?
    var isHighlighted = true
    var isEnabled = false
    var action: (()->Void)
}
