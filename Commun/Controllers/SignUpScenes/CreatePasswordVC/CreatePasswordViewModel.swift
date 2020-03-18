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
    static let lowercaseTitle = "lowercase"
    static let uppercaseTitle = "uppercase"
    static let numberTitle = "number"
    static let minLengthTitle = "min length"

    struct Constraint {
        var symbol: String
        var title: String
        var isSastified = false
    }
    
    let constraints = BehaviorRelay<[Constraint]>(value: [
        Constraint(symbol: "a", title: lowercaseTitle),
        Constraint(symbol: "A", title: uppercaseTitle),
        Constraint(symbol: "1", title: numberTitle),
        Constraint(symbol: "\(AuthManager.minPasswordLength)+", title: minLengthTitle)
    ])
    
    let isShowingPassword = BehaviorRelay<Bool>(value: false)
    
    func validate(password: String) -> Bool {
        let hasLowercasedCharacter = password.contains(where: {$0.isLowercase})
        let hasUppercasedCharacter = password.contains(where: {$0.isUppercase})
        let containsNumber = password.containsNumber
        let isMoreThanMinPasswordLength = password.count >= AuthManager.minPasswordLength
        let isMoreThanMaxPasswordLength = password.count <= AuthManager.maxPasswordLength
        
        // modify constraints
        let constraints = self.constraints.value.map {constraint -> Constraint in
            var constraint = constraint
            switch constraint.title {
            case CreatePasswordViewModel.lowercaseTitle:
                constraint.isSastified = hasLowercasedCharacter
            case CreatePasswordViewModel.uppercaseTitle:
                constraint.isSastified = hasUppercasedCharacter
            case CreatePasswordViewModel.numberTitle:
                constraint.isSastified = containsNumber
            case CreatePasswordViewModel.minLengthTitle:
                constraint.isSastified = isMoreThanMinPasswordLength
            default:
                break
            }
            return constraint
        }
        self.constraints.accept(constraints)
        
        return hasLowercasedCharacter && hasUppercasedCharacter && containsNumber && isMoreThanMinPasswordLength && isMoreThanMaxPasswordLength
    }
}
