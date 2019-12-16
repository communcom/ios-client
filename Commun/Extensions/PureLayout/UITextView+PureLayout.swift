//
//  UITextView+PureLayout.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import PureLayout

extension UITextView {
    public convenience init(forExpandable: ()) {
        self.init(forAutoLayout: ())
        isScrollEnabled = false
    }
}
