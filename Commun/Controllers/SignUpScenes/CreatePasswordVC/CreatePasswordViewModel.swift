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
        var isSastified = false
    }
    
    let constraints = BehaviorRelay<[Constraint]>(value: [
        Constraint(symbol: "a", title: "lowercase"),
        Constraint(symbol: "A", title: "uppercase"),
        Constraint(symbol: "1", title: "number"),
        Constraint(symbol: "\(AuthManager.minPasswordLength)+", title: "min length")
    ])
    
    let isShowingPassword = BehaviorRelay<Bool>(value: false)
    
    func validate(password: String) -> Bool {
        let hasLowercasedCharacter = password.contains(where: {$0.isLowercase})
        let hasUppercasedCharacter = password.contains(where: {$0.isUppercase})
        let containsNumber = password.containsNumber
        let isMoreThanMinPasswordLength = password.count >= AuthManager.minPasswordLength
        
        // modify constraints
        let constraints = self.constraints.value.map {constraint -> Constraint in
            var constraint = constraint
            switch constraint.title {
            case "lowercase":
                constraint.isSastified = hasLowercasedCharacter
            case "uppercase":
                constraint.isSastified = hasUppercasedCharacter
            case "number":
                constraint.isSastified = containsNumber
            case "min length":
                constraint.isSastified = isMoreThanMinPasswordLength
            default:
                break
            }
            return constraint
        }
        self.constraints.accept(constraints)
        
        return hasLowercasedCharacter && hasUppercasedCharacter && containsNumber && isMoreThanMinPasswordLength
    }
}
