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
    // MARK: - Class Functions
    func checkUserName(_ userName: String) -> [Bool] {
        // Rule 1
        // • The number of characters must not exceed 32
        // username must be between 5-32 characters
        let isBetween5To32Characters = (userName.count >= 5 && userName.count <= 32)
        
        // Rule 2, 3, 5
        // • Uppercase letters in the username are not allowed
        // • Valid characters: letters, numbers, hyphen
        
        let containsOnlyAllowedCharacters = userName.matches("^[a-z0-9-.]+$")
        
        // Rule 4
        // • The hyphen character cannot be at the beginning or at the end of the username
        let nonAlphanumericCharacterIsNotAtBeginOrEnd = !userName.starts(with: "-") && !userName.ends(with: "-") && !userName.starts(with: ".") && !userName.ends(with: ".")

        // Rule 6
        // • The presence of two characters "dot" in a row is not valid
        let twoNonAlphanumericCharacterNotSideBySide = !userName.contains(".-") && !userName.contains("-.") && !userName.contains("--")
        
        // Rule 7
        // • The user name may contain a "dot" character
        let onlyOneDot = userName.count(of: ".") <= 1
        
        return [
            isBetween5To32Characters,
            containsOnlyAllowedCharacters,
            twoNonAlphanumericCharacterNotSideBySide,
            nonAlphanumericCharacterIsNotAtBeginOrEnd,
            onlyOneDot
        ]
    }
    
    func isUserNameValid(_ userName: String) -> Bool {
        return checkUserName(userName).reduce(true, { (result, element) -> Bool in
            return result && element
        })
    }
    
    func set(userName: String) -> Single<String> {
        return RestAPIManager.instance.setUserName(userName).map {_ in userName}
    }
}
