//
//  UINavigationController.swift
//  Commun
//
//  Created by Chung Tran on 2/14/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension UINavigationController {
    func popToVC<T: UIViewController>(type: T.Type, completion: ((T) -> Void)? = nil) {
        if let vc = viewControllers.filter({ $0 is T }).first as? T {
            popToViewController(vc, animated: true)
            completion?(vc)
        }
    }
}
