//
//  WalletConvertVC.swift
//  Commun
//
//  Created by Chung Tran on 12/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class WalletConvertVC: BaseViewController {
    // MARK: - Properties
    let viewModel = BalancesViewModel()
    var currentSymbol: String?
    let currentBalance = BehaviorRelay<ResponseAPIWalletGetBalance?>(value: nil)
    var buyContainerRightConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var balanceNameLabel = UILabel.with(textSize: 17, weight: .semibold, textColor: .white)
    lazy var valueLabel = UILabel.with(textSize: 30, weight: .semibold, textColor: .white)
    lazy var whiteView = UIView(backgroundColor: .white)
    lazy var buyContainer: UIView = {
        let view = UIView(cornerRadius: 10)
        view.borderColor = .e2e6e8
        view.borderWidth = 1
        return view
    }()
    lazy var buyLogoImageView = MyAvatarImageView(size: 40)
    lazy var buyNameLabel = UILabel.with(textSize: 15, weight: .medium)
    lazy var buyBalanceLabel = UILabel.with(textSize: 15, weight: .medium)
    
    lazy var convertContainer = UIStackView(axis: .horizontal, spacing: 10)
    lazy var convertSellLabel = UILabel.with(text: "Sell", textSize: 12, weight: .medium, textColor: .a5a7bd)
    lazy var sellTextField = createTextField()
    lazy var convertBuyLabel = UILabel.with(text: "Buy", textSize: 12, weight: .medium, textColor: .a5a7bd)
    lazy var buyTextField = createTextField()
    
    private func createTextField() -> UITextField {
        let textField = UITextField(backgroundColor: .clear)
        textField.placeholder = "0"
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 17, weight: .semibold)
        textField.setPlaceHolderTextColor(.a5a7bd)
        return textField
    }
    
    lazy var rateLabel = UILabel.with(text: "Rate: ", textSize: 12, weight: .medium, textAlignment: .center)
    
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
        layoutCarousel()
        balanceNameLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        blackView.addSubview(valueLabel)
        valueLabel.autoPinEdge(.top, to: .bottom, of: balanceNameLabel, withOffset: 5)
        valueLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        valueLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 55)
        
        view.addSubview(whiteView)
        whiteView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        whiteView.autoPinEdge(.top, to: .bottom, of: blackView, withOffset: -25)
        
        let convertLogoView: UIView = {
            let view = UIView(width: 40, height: 40, backgroundColor: .appMainColor, cornerRadius: 20)
            view.borderWidth = 2
            view.borderColor = .white
            let imageView = UIImageView(width: 23, height: 19, imageNamed: "wallet-convert")
            view.addSubview(imageView)
            imageView.autoAlignAxis(toSuperviewAxis: .vertical)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            return view
        }()
        
        view.addSubview(convertLogoView)
        convertLogoView.autoPinEdge(.top, to: .top, of: whiteView, withOffset: -20)
        convertLogoView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // Buy container
        layoutBuyContainer()
        
        // convert view
        layoutConvertView()
        
        // rate label
        whiteView.addSubview(rateLabel)
        rateLabel.autoPinEdge(.top, to: .bottom, of: convertContainer, withOffset: 20)
        rateLabel.autoAlignAxis(toSuperviewAxis: .vertical)
    }
    
    func layoutCarousel() {
        balanceNameLabel.autoPinEdge(toSuperviewSafeArea: .top, withInset: 20)
    }
    
    func layoutBuyContainer() {
        whiteView.addSubview(buyContainer)
        buyContainer.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 40, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
        
        buyContainer.addSubview(buyLogoImageView)
        buyLogoImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .trailing)
        
        let buyLabel = UILabel.with(text: "buy".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .a5a7bd)
        buyContainer.addSubview(buyLabel)
        buyLabel.autoPinEdge(.top, to: .top, of: buyLogoImageView)
        buyLabel.autoPinEdge(.leading, to: .trailing, of: buyLogoImageView, withOffset: 10)
        
        buyContainer.addSubview(buyNameLabel)
        buyNameLabel.autoPinEdge(.top, to: .bottom, of: buyLabel, withOffset: 2)
        buyNameLabel.autoPinEdge(.leading, to: .leading, of: buyLabel)
        
        let balanceLabel = UILabel.with(text: "balance".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .a5a7bd)
        buyContainer.addSubview(balanceLabel)
        balanceLabel.autoPinEdge(.top, to: .top, of: buyLogoImageView)
        buyContainerRightConstraint = balanceLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        buyContainer.addSubview(buyBalanceLabel)
        buyBalanceLabel.autoPinEdge(.top, to: .bottom, of: balanceLabel, withOffset: 2)
        buyBalanceLabel.autoPinEdge(.trailing, to: .trailing, of: balanceLabel)
        buyBalanceLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        buyBalanceLabel.autoPinEdge(.leading, to: .trailing, of: buyNameLabel, withOffset: 10)
    }
    
    func layoutConvertView() {
        whiteView.addSubview(convertContainer)
        convertContainer.autoPinEdge(.top, to: .bottom, of: buyContainer, withOffset: 10)
        convertContainer.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        convertContainer.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        let firstView: UIView = {
            let view = UIView(cornerRadius: 10)
            view.borderColor = .e2e6e8
            view.borderWidth = 1
            return view
        }()
        firstView.addSubview(convertSellLabel)
        convertSellLabel.autoPinTopAndLeadingToSuperView(inset: 10, xInset: 16)
        
        firstView.addSubview(sellTextField)
        sellTextField.autoPinEdge(.top, to: .bottom, of: convertSellLabel, withOffset: 8)
        sellTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16), excludingEdge: .top)
        
        convertContainer.addArrangedSubview(firstView)
        
        let secondView: UIView = {
            let view = UIView(cornerRadius: 10)
            view.borderColor = .e2e6e8
            view.borderWidth = 1
            return view
        }()
        secondView.addSubview(convertBuyLabel)
        convertBuyLabel.autoPinTopAndLeadingToSuperView(inset: 10, xInset: 16)
        
        let equalLabel = UILabel.with(text: "= ", textSize: 17, weight: .semibold, textColor: .a5a7bd)
        equalLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        secondView.addSubview(equalLabel)
        equalLabel.autoPinEdge(.top, to: .bottom, of: convertBuyLabel, withOffset: 8)
        equalLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        secondView.addSubview(buyTextField)
        buyTextField.autoPinEdge(.top, to: .bottom, of: convertBuyLabel, withOffset: 8)
        buyTextField.autoPinEdge(.leading, to: .trailing, of: equalLabel)
        buyTextField.autoPinBottomAndTrailingToSuperView(inset: 10, xInset: 16)
        
        convertContainer.addArrangedSubview(secondView)
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
