//
//  ConfirmUserViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ConfirmUserViewModel {
    
    var pincodeHash = BehaviorRelay<String>(value: "")
    var phone = BehaviorRelay<String>(value: "")
    
    let disposeBag = DisposeBag()
    
    init(pinHash: String, phone: String) {
        self.pincodeHash.accept(pinHash)
        self.phone.accept(phone)
    }
    
    func resendCode() -> Observable<Bool> {
        let resendObservable = NetworkService.shared.resendSmsCode(phone: phone.value)
        resendObservable.bind(to: pincodeHash).disposed(by: disposeBag)
        return resendObservable.map({ code -> Bool in
            return code != ""
        })
        
    }
    
    func checkPin(_ code: String) -> Observable<Bool> {
        let isEqual = code.md5() == pincodeHash.value
        return Observable<Bool>.just(isEqual)
    }
}
