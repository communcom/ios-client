//
//  EditorToolbarItem.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

struct PostEditorToolbarItem: Equatable {
    static func == (lhs: PostEditorToolbarItem, rhs: PostEditorToolbarItem) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name: String
    var icon: String
    var iconSize: CGSize
    var description: String? = nil
    var isHighlighted = false
    var isEnabled = true
    var other: Any? = nil // for colorPicking and other
    
    static var hideKeyboard: PostEditorToolbarItem {
        return PostEditorToolbarItem(
            name: "hideKeyboard",
            icon: "keyboard_hide",
            iconSize: CGSize(width: 18, height: 18))
    }
    
    static var addPhoto: PostEditorToolbarItem {
        return PostEditorToolbarItem(
            name: "addPhoto",
            icon: "editor-open-photo",
            iconSize: CGSize(width: 18, height: 18))
    }
    
    static var setBold: PostEditorToolbarItem {
        return PostEditorToolbarItem(
            name: "setBold",
            icon: "bold",
            iconSize: CGSize(width: 18, height: 18))
    }
    static var setItalic: PostEditorToolbarItem {
        return PostEditorToolbarItem(
            name: "setItalic",
            icon: "italic",
            iconSize: CGSize(width: 18, height: 18))
    }
    static var setColor: PostEditorToolbarItem {
        return PostEditorToolbarItem(
            name: "setColor",
            icon: "--missing--",
            iconSize: .zero,
            other: UIColor.black)
    }
    
    static var addLink: PostEditorToolbarItem {
        return PostEditorToolbarItem(
            name: "addLink",
            icon: "add_link",
            iconSize: CGSize(width: 18, height: 18))
    }
    
    static var clearFormatting: PostEditorToolbarItem {
        return PostEditorToolbarItem(
            name: "clearFormatting",
            icon: "clear-formatting",
            iconSize: CGSize(width: 18, height: 18))
    }
    
    static var addArticle: PostEditorToolbarItem {
        return PostEditorToolbarItem(
            name: "addArticle",
            icon: "editor-open-article",
            iconSize: CGSize(width: 19, height: 19),
            description: "article")
    }
}
