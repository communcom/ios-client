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
    // MARK: - Nested type
    enum ConvertError: Error {
        case insufficientFunds
        case other(Error)
    }
    
    let priceLoadingState = BehaviorRelay<LoadingState>(value: .loading)
    let buyPrice = BehaviorRelay<Double>(value: 0)
    let sellPrice = BehaviorRelay<Double>(value: 0)
    let errorSubject = BehaviorRelay<ConvertError?>(value: nil)
    
    let rate = BehaviorRelay<Double>(value: 0)
    
    // Prevent duplicating
    private var currentBuyPriceSymbol: String?
    private var currentBuyPriceQuantity: String?
    private var currentSellPriceQuantity: String?
    
    func getBuyPrice(symbol: String, quantity: String) {
        // save current (for comparison
        currentBuyPriceSymbol = symbol
        currentBuyPriceQuantity = quantity
        
        // reset error
        errorSubject.accept(nil)
        
        // set state
        priceLoadingState.accept(.loading)
        RestAPIManager.instance.getBuyPrice(symbol: symbol, quantity: quantity)
            .subscribe(onSuccess: { [weak self] result in
                self?.priceLoadingState.accept(.finished)
                // prevent duplicating
                if result.symbol == self?.currentBuyPriceSymbol && result.quantity == self?.currentBuyPriceQuantity
                {
                    self?.buyPrice.accept(result.priceValue)
                }
                
            }, onError: { [weak self] (error) in
                self?.errorSubject.accept(.other(error))
                self?.priceLoadingState.accept(.error(error: error))
            })
            .disposed(by: disposeBag)
    }
    
    func getSellPrice(quantity: String) {
        // save current (for comparison
        currentSellPriceQuantity = quantity
        
        // reset error
        errorSubject.accept(nil)
        
        // set state
        priceLoadingState.accept(.loading)
        RestAPIManager.instance.getSellPrice(quantity: quantity)
            .subscribe(onSuccess: { [weak self] result in
                self?.priceLoadingState.accept(.finished)
                // prevent duplicating
                if result.quantity == self?.currentSellPriceQuantity {
                    self?.sellPrice.accept(result.priceValue)
                }
            }, onError: { [weak self] (error) in
                self?.errorSubject.accept(.other(error))
                self?.priceLoadingState.accept(.error(error: error))
            })
            .disposed(by: disposeBag)
    }
    
    func getRate(symbol: String) {
        RestAPIManager.instance.getBuyPrice(symbol: symbol, quantity: "10 CMN")
            .subscribe(onSuccess: { [weak self] result in
                self?.rate.accept(result.priceValue)
            })
            .disposed(by: disposeBag)
    }
}
