//
//  SignUpViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
    
    // MARK: - Custom Functions4
    func validatePhoneNumber() -> Bool {
        guard let selectedCountry = selectedCountry.value else {
            return false
        }

        do {
            _ = try PhoneNumberKit().parse(self.phone.value, withRegion: selectedCountry.countryCode, ignoreType: false)
            return true
        } catch {
            return false
        }
    }
}
