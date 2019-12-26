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
    let priceLoadingState = BehaviorRelay<LoadingState>(value: .loading)
    let buyPrice = BehaviorRelay<Double>(value: 0)
    let sellPrice = BehaviorRelay<Double>(value: 0)
    
    func getBuyPrice(symbol: String, quantity: String) {
        priceLoadingState.accept(.loading)
        RestAPIManager.instance.getBuyPrice(symbol: symbol, quantity: quantity)
            .subscribe(onSuccess: { [weak self] result in
                self?.priceLoadingState.accept(.finished)
                self?.buyPrice.accept(result.priceValue)
            }, onError: { [weak self] (error) in
                self?.priceLoadingState.accept(.error(error: error))
            })
            .disposed(by: disposeBag)
    }
    
    func getSellPrice(quantity: String) {
        priceLoadingState.accept(.loading)
        RestAPIManager.instance.getSellPrice(quantity: quantity)
            .subscribe(onSuccess: { [weak self] result in
                self?.priceLoadingState.accept(.finished)
                self?.sellPrice.accept(result.priceValue)
            }, onError: { [weak self] (error) in
                self?.priceLoadingState.accept(.error(error: error))
            })
            .disposed(by: disposeBag)
    }
}
