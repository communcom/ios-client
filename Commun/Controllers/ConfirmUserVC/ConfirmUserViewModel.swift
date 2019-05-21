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
    init(code: String, phone: String) {
        self.pincode.accept(code)
        self.phone.accept(phone)
    }

    
    // MARK: - Class Functions
    func checkPin(_ code: String) -> Observable<Bool> {
        let isEqual = (code == pincode.value) || (code == String(describing: smsCodeDebug))
        return Observable<Bool>.just(isEqual)
    }
    
    func verifyUser() -> Observable<Bool> {
        return NetworkService.shared.userVerify(phone: phone.value, code: pincode.value)
    }
}
