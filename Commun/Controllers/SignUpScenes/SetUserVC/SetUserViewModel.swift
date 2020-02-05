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
    func checkUserName(_ userName: String) -> [Bool] {
        guard !userName.isEmpty else { return [false, false, false, false, false, false] }
        // Rule 0
        let isStartWithALetter = userName.matches("^[a-z].*$")
        
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
        let twoNonAlphanumericCharacterNotSideBySide = !userName.contains("..") && !userName.contains(".-") && !userName.contains("-.") && !userName.contains("--")
        
        // Rule 7
        // • Each user name segment should start with a letter
        let segments = userName.components(separatedBy: ".").filter({ !$0.isEmpty })
        var segmentsStartLetter = true
        var segmentLength = true
        
        if segments.count > 0 {
            segmentsStartLetter = segments.filter({ Character($0.prefix(1).description).isNumber == true }).count == 0
            segmentLength = segments.filter({ $0.count < 5}).count == 0
        }
        
        var message: String?
        if !isStartWithALetter {
            message = "username should start with a letter"
        }
        
        if message == nil && !isBetween5To32Characters {
            message = "username must be between 5-32 characters"
        }
        
        if message == nil && !containsOnlyAllowedCharacters {
            message = "only non-uppercased letters, numbers and hyphen are allowed"
        }
        
        if message == nil && !nonAlphanumericCharacterIsNotAtBeginOrEnd {
            message = "the hyphen character cannot be at the beginning or at the end of the username"
        }
        
        if message == nil && !twoNonAlphanumericCharacterNotSideBySide {
            message = "the presence of two \"dots\" or two \"hyphens\" in a row is not valid"
        }
        
        if message == nil && !segmentsStartLetter {
            message = "each username segment should start with a letter"
        }
        
        if message == nil && !segmentLength {
            message = "each username segment should contains 5 or more letters"
        }
        
        errorMessage.accept(message)
        
        return [
            isStartWithALetter,
            isBetween5To32Characters,
            containsOnlyAllowedCharacters,
            twoNonAlphanumericCharacterNotSideBySide,
            nonAlphanumericCharacterIsNotAtBeginOrEnd,
            segmentsStartLetter,
            segmentLength
        ]
    }
    
    func isUserNameValid(_ userName: String) -> Bool {
        checkUserName(userName).allSatisfy {$0}
    }
    
    func set(userName: String) -> Single<String> {
        return RestAPIManager.instance.setUserName(userName).map {_ in userName}
    }
}
