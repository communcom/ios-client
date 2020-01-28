//
//  BuyCommunViewModel.swift
//  Commun
//
//  Created by Chung Tran on 1/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa
import CyberSwift
import RxSwift

class BuyCommunViewModel {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let loadingState = BehaviorRelay<LoadingState>(value: .loading)
    lazy var currenciesVM: CurrenciesViewModel = {
        let fetcher = CurrenciesListFetcher()
        return CurrenciesViewModel()
    }()
    let currentCurrency = BehaviorRelay<ResponseAPIGetCurrency?>(value: nil)
    let minMaxAmount = BehaviorRelay<ResponseAPIGetMinMaxAmount?>(value: nil)
    let expectedAmount = BehaviorRelay<Double?>(value: nil)
    
    // MARK: - Methods
    init() {
        bind()
    }
    
    private func bind() {
        // loading state
        currenciesVM.state
            .bind { [weak self] state in
                switch state {
                case .loading(let isLoading):
                    if isLoading {
                        self?.loadingState.accept(.loading)
                    }
                case .listEmpty, .listEnded:
                    self?.loadingState.accept(.finished)
                case .error(let error):
                    self?.loadingState.accept(.error(error: error))
                }
            }
            .disposed(by: disposeBag)
        
        // bind currenciesVM
        currenciesVM.items
            .subscribe(onNext: { [weak self] (items) in
                self?.bindCurrencies(items)
            })
            .disposed(by: disposeBag)
        
        // bind currentCurrency
        currentCurrency
            .subscribe(onNext: {[weak self] (currency) in
                self?.getMinMaxAmount()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindCurrencies(_ currencies: [ResponseAPIGetCurrency]) {
        // update currentCurrency
        if let currency = currencies.first(where: {$0.name == self.currentCurrency.value?.name || $0.name.uppercased() == "BTC"}) {
            currentCurrency.accept(currency)
        }
    }
    
    private func getMinMaxAmount() {
        guard let currentSymbol = currentCurrency.value?.name.uppercased() else {return}
        RestAPIManager.instance.exchangeGetMinMaxAmount(from: currentSymbol, to: "CMN")
            .subscribe(onSuccess: { [weak self] (amount) in
                self?.minMaxAmount.accept(amount)
            }) { [weak self] (error) in
                self?.loadingState.accept(.error(error: error))
            }
            .disposed(by: disposeBag)
    }
    
    func getExpectedAmount(from: String, to: String, amount: Double) -> Single<Double> {
        RestAPIManager.instance.getExchangeAmount(from: from, to: to, amount: amount)
            .map {Double($0) ?? 0}
    }
}
