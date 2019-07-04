//
//  ConfirmUserViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation
import CyberSwift

class ConfirmUserViewModel {
    // MARK: - Properties
    var pincode = BehaviorRelay<String>(value: "")
    var phone = BehaviorRelay<String>(value: "")
    
    let disposeBag = DisposeBag()
    
    
    // MARK: - Class Initialization
    init?() {
        guard let user = Config.currentUser,
            let code = user.smsCode,
            let phone = user.phoneNumber else {
                return nil
        }
        self.pincode.accept("\(code)")
        self.phone.accept(phone)
    }

    
    // MARK: - Class Functions
    func isPinValid(_ code: String) -> Bool {
        return (code == pincode.value) || (code == String(describing: smsCodeDebug))
    }
}
