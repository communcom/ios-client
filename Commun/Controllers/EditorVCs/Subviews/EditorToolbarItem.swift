//
//  EditorToolbarItem.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

struct EditorToolbarItem {
    var name: String
    var icon: String
    var iconSize: CGSize
    var description: String?
    var isEnabled = true
    var action: (()->Void)
}
