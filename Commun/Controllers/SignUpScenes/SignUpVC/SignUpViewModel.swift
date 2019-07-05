//
//  SignUpViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PhoneNumberKit
import CyberSwift

class SignUpViewModel {
    // MARK: - Properties
    let phone = BehaviorRelay<String>(value: "")
    let selectedCountry = BehaviorRelay<Country?>(value: nil)
    
    let errorSubject = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    func validatePhoneNumber() -> Bool {
        guard let selectedContry = selectedCountry.value else {
            return false
        }
        
        let phone = self.phone.value
        
        let phoneNumberKit = PhoneNumberKit()
        
        do {
            let _ = try phoneNumberKit.parse(phone, withRegion: selectedContry.shortCode , ignoreType: true)
            return true
        } catch {
            return false
        }
    }
}
