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
//    func resendCode() -> Observable<Bool> {
//        let resendObservable = NetworkService.shared.resendSmsCode(phone: phone.value)
//        resendObservable.bind(to: pincode).disposed(by: disposeBag)
//        return resendObservable.map({ code -> Bool in
//            return code != ""
//        })
//        
//    }
    
    func checkPin(_ code: String) -> Observable<Bool> {
        #if DEBUG
        let isEqual = (code == pincode.value) || (code == "9999")
        #else
        let isEqual = code == pincode.value
        #endif
        return Observable<Bool>.just(isEqual)
    }
    
    func verifyUser() -> Observable<Bool> {
        return NetworkService.shared.userVerify(phone: phone.value, code: pincode.value)
    }
}
