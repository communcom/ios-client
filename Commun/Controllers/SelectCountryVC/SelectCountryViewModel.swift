//
//  SelectCountryViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

struct Country: Decodable {
    let code: String
    let name: String
    let countryCode: String
    let available: Bool
    let emoji: String
}

class SelectCountryViewModel {
    // MARK: - Properties
    let search = BehaviorRelay<String>(value: "")
    let countries = BehaviorRelay<[Country]>(value: SelectCountryViewModel.getCountriesList())
    let selectedCountry = BehaviorRelay<Country?>(value: nil)
    let disposeBag = DisposeBag()
    
    // MARK: - Class Initialization
    init(withModel model: SignUpViewModel) {
        let countries = SelectCountryViewModel.getCountriesList()
        
        search
            .filter { text -> Bool in
                return text.count > 0
            }
            .map { text -> [Country] in
                var result: [Country] = []
                
                for country in countries {
                    if country.name.capitalized.contains(text.capitalized) {
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
                return country?.available ?? false
            }
            .bind(to: model.selectedCountry)
            .disposed(by: disposeBag)
    }

    static func getCountriesList() -> [Country] {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "countries", ofType: "json")!), options: .mappedIfSafe)
        let countries = try! JSONDecoder().decode([Country].self, from: data)
        let countriesByCode = countries.sorted(by: { Int($0.code)! < Int($1.code)! })
        return countriesByCode.sorted(by: { $0.available == true && $1.available == false})
    }
}
