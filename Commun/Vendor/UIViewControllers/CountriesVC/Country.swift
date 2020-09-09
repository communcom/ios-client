//
//  Country.swift
//  Commun
//
//  Created by Chung Tran on 3/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

// MARK: - Nested type
struct Language: Decodable {
    let code: String
    let name: String?
}

struct Country: Decodable {
    let code: String
    let name: String
    let countryCode: String
    let available: Bool
    let emoji: String
    let language: Language?
    
    static func getAll() -> [Country] {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "countries", ofType: "json")!), options: .mappedIfSafe)
        let countries = try! JSONDecoder().decode([Country].self, from: data)
        let countriesByCode = countries.sorted(by: { Int($0.code)! < Int($1.code)! })
        return countriesByCode.sorted(by: { $0.available == true && $1.available == false})
    }
}
