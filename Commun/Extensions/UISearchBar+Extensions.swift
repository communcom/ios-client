//
//  UISearchBar+Extensions.swift
//  Commun
//
//  Created by Chung Tran on 3/2/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension UISearchBar {
    static func `default`(
        placeholder: String = "search".localized().uppercaseFirst
    ) -> UISearchBar {
        let sc = UISearchBar(frame: .zero)
        sc.tintColor = .appMainColor
        sc.setStyle(placeholder: placeholder)
        return sc
    }
    
    func setStyle(placeholder: String = "search".localized().uppercaseFirst) {
        let searchTextField: UITextField

        if #available(iOS 13, *) {
            searchTextField = self.searchTextField
        } else {
            searchTextField = (value(forKey: "searchField") as? UITextField) ?? UITextField()
        }

        // Not work in ios 12
//        // change bg color
//        searchTextField.backgroundColor = .appLightGrayColor
//
//        // remove top tinted black view
//        let backgroundView = searchTextField.subviews.first
//        backgroundView?.subviews.forEach({ $0.removeFromSuperview() })
        
        // support ios 12
        for subView in subviews
        {
            for subView1 in subView.subviews where subView1 is UITextField
            {
                subView1.backgroundColor = UIColor.appLightGrayColor
            }
        }

        // change icon color
        if let iconView = searchTextField.leftView as? UIImageView {
            iconView.image = iconView.image?.withRenderingMode(.alwaysTemplate)
            iconView.tintColor = .appGrayColor
        }

        // change placeholder color (add new label)
        if let systemPlaceholderLabel = searchTextField.value(forKey: "placeholderLabel") as? UILabel {
            self.placeholder = " "

            let placeholderLabel = UILabel(frame: .zero)

            placeholderLabel.text = placeholder
            placeholderLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
            placeholderLabel.textColor = .appGrayColor

            systemPlaceholderLabel.addSubview(placeholderLabel)

            // Layout label to be a "new" placeholder
            placeholderLabel.leadingAnchor.constraint(equalTo: systemPlaceholderLabel.leadingAnchor).isActive = true
            placeholderLabel.topAnchor.constraint(equalTo: systemPlaceholderLabel.topAnchor).isActive = true
            placeholderLabel.bottomAnchor.constraint(equalTo: systemPlaceholderLabel.bottomAnchor).isActive = true
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
            placeholderLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        } else {
            self.placeholder = placeholder
        }
    }
    
    func roundCorner(cornerRadius: CGFloat? = nil) {
        textField?.cornerRadius = cornerRadius ?? ((textField?.height ?? 0) / 2)
    }
    
    func changeTextNotified(text: String) {
        self.text = text
        delegate?.searchBar?(self, textDidChange: text)
    }
}
