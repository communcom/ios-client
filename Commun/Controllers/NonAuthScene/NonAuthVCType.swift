//
//  NonAuthVCType.swift
//  Commun
//
//  Created by Chung Tran on 7/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol NonAuthVCType: UIViewController {}

extension NonAuthVCType {
    func showAuthVC() {
        let vc: UIViewController = self.tabBarController ?? self
        let controller = BaseNavigationController(rootViewController: SignUpVC())
        vc.show(controller, sender: nil)
    }
}
