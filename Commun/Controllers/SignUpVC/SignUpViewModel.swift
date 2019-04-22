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

class SignUpViewModel {
    
    let country = BehaviorRelay<String>(value: "Select country")
    let flagUrl = BehaviorRelay<URL?>(value: nil)
    
    let phone = BehaviorRelay<String>(value: "")
    
    let selectedCountry = BehaviorRelay<Country?>(value: nil)
    
    let errorSubject = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    init() {
        selectedCountry.filter { country -> Bool in
            return country != nil
        }.map { country -> String in
            return country!.label
        }.bind(to: country).disposed(by: disposeBag)
        
        selectedCountry.filter { country -> Bool in
            return country != nil
        }.map { country -> URL in
            return country!.flagURL
        }.bind(to: flagUrl).disposed(by: disposeBag)
    }
    
    func signUp() -> Observable<UInt64> {
        return NetworkService.shared.signUp(withPhone: phone.value).map { result -> UInt64 in
            return result.code
        }
    }
    
    func validatePhoneNumber() -> Bool {
        var phone = self.phone.value
        
        if phone.contains("+") == false {
            phone = "+\(phone)"
        }
        
        let phoneNumberKit = PhoneNumberKit()
        do {
            let _ = try phoneNumberKit.parse(phone, withRegion: selectedCountry.value?.shortCode ?? "", ignoreType: true)
            return true
        }
        catch {
            return false
        }
    }
}
