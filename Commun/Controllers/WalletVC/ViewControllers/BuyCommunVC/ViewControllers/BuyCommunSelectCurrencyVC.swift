//
//  BuyCommunSelectCurrencyVC.swift
//  Commun
//
//  Created by Chung Tran on 1/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class BuyCommunSelectCurrencyVC: CurrenciesVC {
    var completion: ((ResponseAPIGetCurrency) -> Void)?
    
    override func modelSelected(_ item: ResponseAPIGetCurrency) {
        completion?(item)
        back()
    }
}
