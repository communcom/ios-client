//
//  SetUserViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation
import CyberSwift

class SetUserViewModel {
    // MARK: - Class Functions
    func checkUserName(_ userName: String) -> [Bool] {
        // username must be between 5-32 characters
        let isBetween5To32Characters =
            (userName.count >= 5 && userName.count <= 32)
        
        // only alphanumeric, non-uppercased characters, "-" and "." are allowed
        let containsOnlyAllowedCharacters = userName.matches("^[a-z0-9-.]+$")
        
        // the presence of two dots side by side is not allowed
        let twoNonAlphanumericCharacterNotSideBySide = !userName.contains("..") && !userName.contains(".-") && !userName.contains("-.") && !userName.contains("--")
        
        // the hyphen character "-" cannot be at the beginning or end of a username.
        let nonAlphanumericCharacterIsNotAtBeginOrEnd = !userName.starts(with: "-") && !userName.ends(with: "-") &&
            !userName.starts(with: ".") && !userName.ends(with: ".")
        
        return [
            isBetween5To32Characters,
            containsOnlyAllowedCharacters,
            twoNonAlphanumericCharacterNotSideBySide,
            nonAlphanumericCharacterIsNotAtBeginOrEnd
        ]
    }
    
    func isUserNameValid(_ userName: String) -> Bool {
        return checkUserName(userName)
            .reduce(true, { (result, element) -> Bool in
                return result && element
            })
    }
    
    func set(userName: String) -> Single<String> {
        return RestAPIManager.instance.rx.setUserName(userName)
            .map {_ in userName}
    }
}
