//
//  UISearchController.swift
//  Commun
//
//  Created by Chung Tran on 1/29/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension UISearchController {
    static func `default`(placeholder: String = "search".localized().uppercaseFirst) -> UISearchController {
        let sc = UISearchController(searchResultsController: nil)
        if let textfield = sc.searchBar.value(forKey: "searchField") as? UITextField {
            //textfield.textColor = // Set text color
            if let backgroundview = textfield.subviews.first {

                // Background color
                backgroundview.backgroundColor = .f3f5fa

                // Rounded corner
                backgroundview.cornerRadius = sc.searchBar.height
            }
            
            textfield.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.font: UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor.a7a9bf])
            
            if let iconView = textfield.leftView as? UIImageView {
                iconView.tintColor = .a7a9bf
            }
        }
        
        return sc
    }
}
