//
//  SetUserViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SetUserViewModel {
 
    let userName = BehaviorRelay<String>(value: "")
    let phone = BehaviorRelay<String>(value: "")
    
    init(phone: String) {
        self.phone.accept(phone)
    }
    
    func setUser() -> Observable<Bool> {
        return NetworkService.shared.setUser(name: userName.value, phone: phone.value).map({ result -> Bool in
            return result.lowercased() == "success"
        })
    }
    
}
