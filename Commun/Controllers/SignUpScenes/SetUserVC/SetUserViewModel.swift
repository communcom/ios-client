//
//  SetUserViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation

class SetUserViewModel {
    // MARK: - Properties
    let errorMessage = BehaviorRelay<String?>(value: nil)
    
    // MARK: - Class Functions
    func isUserNameValid(_ userName: String) -> Bool {
        errorMessage.accept("")
        guard !userName.isEmpty else { return false }

        // Rule 1
        // Uppercase letters in the username are not allowed
        // Valid characters: letters, numbers, hyphen
        if !userName.matches("^[a-z0-9-.]+$") {
            errorMessage.accept("Username may contain only lower case letters, digits, dots or dashes".localized())
            return false
        }

        // Rule 2
        // only lower case letters, digits, dots or dashes
        if !userName.matches("^[a-z].*$") {
            errorMessage.accept("Username should start with a letter".localized())
            return false
        }
        
        // Rule 3
        // Username should contain at least 3 symbols
        if userName.count < 3 {
            errorMessage.accept("Username should contain at least 3 symbols".localized())
            return false
        }

        // Rule 4
        // Username should have max 32 symbols
        if userName.count > 32 {
            errorMessage.accept("Username is too long. 32 symbols are maximum".localized())
            return false
        }

        // Rule 5
        // Username may contain only one dash in a row
        if userName.contains("--") {
            errorMessage.accept("Username may contain only one dash in a row".localized())
            return false
        }

        // Rule 6
        // Username may contain only one dot in a row
        if userName.contains("..") {
            errorMessage.accept("Username may contain only one dot in a row".localized())
            return false
        }

        // Rule 7
        // Username may contain only one dot or one dash in a row
        if userName.contains(".-") || userName.contains("-.") {
            errorMessage.accept("Username may contain only one dot or one dash in a row".localized())
            return false
        }

        // Rule 8
        // Username should end with a letter or a digit
        if !(userName.last?.string.matches("^[a-z0-9].*$") ?? true) {
            errorMessage.accept("Username should end with a letter or a digit".localized())
            return false
        }
        
        return true
    }
}
