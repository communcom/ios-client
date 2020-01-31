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
        if let textfield = sc.searchBar.textField {
            textfield.backgroundColor = .f3f5fa
            textfield.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.a5a7bd])
            if let iconView = textfield.leftView as? UIImageView {
                iconView.image = iconView.image?.withRenderingMode(.alwaysTemplate)
                iconView.tintColor = .a5a7bd
            }
        }
        
        return sc
    }
}
