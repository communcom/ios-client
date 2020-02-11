//
//  CurrenciesListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 1/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class CurrenciesListFetcher: ListFetcher<ResponseAPIGetCurrency> {
    override var isPaginationEnabled: Bool {false}
    
    override var request: Single<[ResponseAPIGetCurrency]> {
        RestAPIManager.instance.getCurrenciesFull()
    }
}
