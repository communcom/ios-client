//
//  NonAuthVCType.swift
//  Commun
//
//  Created by Chung Tran on 7/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol NonAuthVCType: BaseViewController {}

extension NonAuthVCType {
    func showAuthVC() {
        // TODO: - Show Auth
        showAlert(title: "TODO", message: "Authorization needed")
    }
}
