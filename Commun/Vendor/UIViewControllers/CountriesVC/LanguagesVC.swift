//
//  LanguagesVC.swift
//  Commun
//
//  Created by Chung Tran on 9/9/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class LanguagesVC: CountriesVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "choose language".localized().uppercaseFirst
    }
    
    override func mapItems(_ countries: [Country]) -> [Country] {
        countries.filter {$0.language != nil}
    }
    
    override func configureCell(index: Int, model: Country, cell: UITableViewCell) {
        let cell = cell as! CountryCell
        cell.setUpLanguage(model)
    }
}
