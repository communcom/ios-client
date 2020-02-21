//
//  UISearchController.swift
//  Commun
//
//  Created by Chung Tran on 1/29/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension UISearchController {
    static func `default`(
        placeholder: String = "search".localized().uppercaseFirst
    ) -> UISearchController {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.searchBarStyle = .minimal
        sc.setStyle(placeholder: placeholder)
        return sc
    }
    
    func setStyle(placeholder: String = "search".localized().uppercaseFirst) {
        if let textfield = searchBar.textField {
            textfield.backgroundColor = .f3f5fa
            textfield.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.a5a7bd])
            if let iconView = textfield.leftView as? UIImageView {
                iconView.image = iconView.image?.withRenderingMode(.alwaysTemplate)
                iconView.tintColor = .a5a7bd
            }
        }
        // Don't hide the navigation bar because the search bar is in it.
        hidesNavigationBarDuringPresentation = false
        obscuresBackgroundDuringPresentation = false
    }
    
    func roundCorner(cornerRadius: CGFloat? = nil) {
        searchBar.textField?.cornerRadius = cornerRadius ?? ((searchBar.textField?.height ?? 0) / 2)
    }
}
