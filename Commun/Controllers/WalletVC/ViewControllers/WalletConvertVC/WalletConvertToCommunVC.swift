//
//  WalletConvertVC.swift
//  Commun
//
//  Created by Chung Tran on 12/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class WalletConvertToCommunVC: BaseViewController {
    // MARK: - Properties
    let viewModel = BalancesViewModel()
    var currentSymbol: String?
    let currentBalance = BehaviorRelay<ResponseAPIWalletGetBalance?>(value: nil)
    
    // MARK: - Subviews
    lazy var balanceNameLabel = UILabel.with(textSize: 17, weight: .semibold, textColor: .white)
    lazy var valueLabel = UILabel.with(textSize: 30, weight: .semibold, textColor: .white)
    lazy var whiteView = UIView(backgroundColor: .white)
    
    // MARK: - Initializers
    init(symbol: String? = nil) {
        currentSymbol = symbol == "CMN" ? nil : symbol
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "convert".localized().uppercaseFirst
        setLeftNavBarButtonForGoingBack(tintColor: .white)
        
        let blackView = UIView(backgroundColor: .black)
        view.addSubview(blackView)
        blackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        blackView.addSubview(balanceNameLabel)
        bindTopOfBlackView()
        balanceNameLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        blackView.addSubview(valueLabel)
        valueLabel.autoPinEdge(.top, to: .bottom, of: balanceNameLabel, withOffset: 5)
        valueLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        valueLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 55)
        
        view.addSubview(whiteView)
        whiteView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        whiteView.autoPinEdge(.top, to: .bottom, of: blackView, withOffset: -25)
        
        let convertView: UIView = {
            let view = UIView(width: 40, height: 40, backgroundColor: .appMainColor, cornerRadius: 20)
            view.borderWidth = 2
            view.borderColor = .white
            let imageView = UIImageView(width: 23, height: 19, imageNamed: "wallet-convert")
            view.addSubview(imageView)
            imageView.autoAlignAxis(toSuperviewAxis: .vertical)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            return view
        }()
        
        view.addSubview(convertView)
        convertView.autoPinEdge(.top, to: .top, of: whiteView, withOffset: -20)
        convertView.autoAlignAxis(toSuperviewAxis: .vertical)
    }
    
    func bindTopOfBlackView() {
        balanceNameLabel.autoPinEdge(toSuperviewSafeArea: .top, withInset: 20)
    }
    
    override func bind() {
        super.bind()
        viewModel.state
            .subscribe(onNext: { (state) in
                switch state {
                case .loading(let isLoading):
                    if isLoading {
                        self.view.showLoading()
                    }
                case .listEnded, .listEmpty:
                    self.view.hideLoading()
                case .error(error: let error):
                    #if !APPSTORE
                        self.showError(error)
                    #endif
                    self.view.hideLoading()
                    self.view.showErrorView {
                        self.view.hideErrorView()
                        self.viewModel.reload()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.items
            .map { (items) -> ResponseAPIWalletGetBalance? in
                if let balance = items.first(where: {$0.symbol == self.currentSymbol}) {
                    return balance
                }
                return items.first(where: {$0.symbol != "CMN"})
            }
            .bind(to: currentBalance)
            .disposed(by: disposeBag)
        
        currentBalance
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { (balance) in
                self.balanceNameLabel.text = balance.name
                self.valueLabel.text = balance.balanceValue.currencyValueFormatted
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = true
        showNavigationBar(false, animated: true, completion: nil)
        self.navigationController?.navigationBar.setTitleFont(.boldSystemFont(ofSize: 17), color: .white)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        whiteView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 25)
    }
    
}
