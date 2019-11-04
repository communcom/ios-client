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
    var description: String? = nil
    var isHighlighted = false
    var isEnabled = true
    var other: Any? = nil // for colorPicking and other
    
    static var hideKeyboard: EditorToolbarItem {
        return EditorToolbarItem(
            name: "hideKeyboard",
            icon: "keyboard_hide",
            iconSize: CGSize(width: 18, height: 18))
    }
    
    static var addPhoto: EditorToolbarItem {
        return EditorToolbarItem(
            name: "addPhoto",
            icon: "editor-open-photo",
            iconSize: CGSize(width: 18, height: 18))
    }
    
    static var setBold: EditorToolbarItem {
        return EditorToolbarItem(
            name: "setBold",
            icon: "bold",
            iconSize: CGSize(width: 18, height: 18))
    }
    static var setItalic: EditorToolbarItem {
        return EditorToolbarItem(
            name: "setItalic",
            icon: "italic",
            iconSize: CGSize(width: 18, height: 18))
    }
    static var setColor: EditorToolbarItem {
        return EditorToolbarItem(
            name: "setColor",
            icon: "--missing--",
            iconSize: .zero,
            other: UIColor.black)
    }
    
    static var addLink: EditorToolbarItem {
        return EditorToolbarItem(
            name: "addLink",
            icon: "add_link",
            iconSize: CGSize(width: 18, height: 18))
    }
    
    static var clearFormatting: EditorToolbarItem {
        return EditorToolbarItem(
            name: "clearFormatting",
            icon: "clear-formatting",
            iconSize: CGSize(width: 18, height: 18))
    }
    
    static var addArticle: EditorToolbarItem {
        return EditorToolbarItem(
            name: "addArticle",
            icon: "editor-open-article",
            iconSize: CGSize(width: 19, height: 19),
            description: "article")
    }
}
