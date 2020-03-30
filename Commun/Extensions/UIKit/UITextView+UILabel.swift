//
//  UITextView+UILabel.swift
//  Commun
//
//  Created by Chung Tran on 8/30/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

protocol HasAttributedString: class {
    var attributedString: NSAttributedString! { get set }
}

//extension HasAttributedString {
//    func parseText(_ text: String) {
//        
//    }
//}

extension UITextView: HasAttributedString {
    var attributedString: NSAttributedString! {
        get {
            return attributedText
        }
        set {
            self.attributedText = newValue
        }
    }
}

extension UILabel: HasAttributedString {
    var attributedString: NSAttributedString! {
        get {
            return attributedText
        }
        set {
            self.attributedText = newValue
        }
    }
}
