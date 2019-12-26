//
//  WalletConvertViewModel.swift
//  Commun
//
//  Created by Chung Tran on 12/26/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class WalletConvertViewModel: BalancesViewModel {
    let buyPriceLoadingState = BehaviorRelay<LoadingState>(value: .loading)
    let price = BehaviorRelay<Double>(value: 0)
    
    func getBuyPrice(symbol: String, quantity: String = "10 CMN") {
        buyPriceLoadingState.accept(.loading)
        RestAPIManager.instance.getBuyPrice(symbol: symbol, quantity: quantity)
            .subscribe(onSuccess: { [weak self] result in
                self?.buyPriceLoadingState.accept(.finished)
                self?.price.accept(result.priceValue)
            }, onError: { [weak self] (error) in
                self?.buyPriceLoadingState.accept(.error(error: error))
            })
            .disposed(by: disposeBag)
    }
}
