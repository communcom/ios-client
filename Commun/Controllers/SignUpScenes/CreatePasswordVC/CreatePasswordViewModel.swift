//
//  CreatePasswordViewModel.swift
//  Commun
//
//  Created by Chung Tran on 3/16/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CreatePasswordViewModel: BaseViewModel {
    struct Constraint {
        var symbol: String
        var title: String
        var isActive = false
    }
    
    let constraints = BehaviorRelay<[Constraint]>(value: [
        Constraint(symbol: "a", title: "lowercase"),
        Constraint(symbol: "A", title: "uppercase"),
        Constraint(symbol: "$", title: "symbol"),
        Constraint(symbol: "8+", title: "min length")
    ])
    
    let isShowingPassword = BehaviorRelay<Bool>(value: false)
}
