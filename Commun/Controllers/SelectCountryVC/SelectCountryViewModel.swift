//
//  SelectCountryViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class SelectCountryViewModel {
    // MARK: - Properties
    let search = BehaviorRelay<String>(value: "")
    let countries = BehaviorRelay<[Country]>(value: PhoneCode.getCountries())
    let selectedCountry = BehaviorRelay<Country?>(value: nil)
    let disposeBag = DisposeBag()
    
    
    // MARK: - Class Initialization
    init(withModel model: SignUpViewModel) {
        let countries = PhoneCode.getCountries()
        
        search
            .filter { text -> Bool in
                return text.count > 0
            }
            .map { text -> [Country] in
                var result: [Country] = []
                
                for country in countries {
                    if country.label.capitalized.contains(text.capitalized) {
                        result.append(country)
                    }
                }
                
                return result
            }
            .bind(to: self.countries)
            .disposed(by: disposeBag)
        
        search
            .filter { text -> Bool in
                return text.count == 0
            }
            .map { _ -> [Country] in
                return countries
            }
            .bind(to: self.countries)
            .disposed(by: disposeBag)
        
        selectedCountry
            .filter { country -> Bool in
                return country != nil
            }
            .bind(to: model.selectedCountry)
            .disposed(by: disposeBag)
    }
}
