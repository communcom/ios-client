//
//  UINavigationBar+Extensions.swift
//  Commun
//
//  Created by Chung Tran on 3/5/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension UINavigationBar {
    func showShadow(_ show: Bool) {
        if show {
            self.addShadow(ofColor: .shadow, radius: 16, offset: CGSize(width: 0, height: 6), opacity: 0.05)
        } else {
            self.shadowOpacity = 0
        }
    }
}
