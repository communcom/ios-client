//
//  WalletConvertVC.swift
//  Commun
//
//  Created by Chung Tran on 12/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class WalletConvertVC: BaseViewController {
    // MARK: - Properties
    let viewModel = WalletConvertViewModel()
    var currentSymbol: String?
    var currentBalance: ResponseAPIWalletGetBalance? {
        didSet {
            setUpCurrentBalance()
        }
    }
    var communBalance: ResponseAPIWalletGetBalance? {
        didSet {
            setUpCommunBalance()
        }
    }
    
    var topColor: UIColor {
        .black
    }
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(axis: .vertical)
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
        textField.keyboardType = .decimalPad
        textField.delegate = self
        return textField
    }
    
    lazy var rateLabel = UILabel.with(text: "Rate: ", textSize: 12, weight: .medium, textAlignment: .center)
    
    lazy var convertButton = CommunButton.default(height: 50, label: "Convert", isHuggingContent: false)
    
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
        
        // backgroundColor
        let topView = UIView(backgroundColor: topColor)
        view.addSubview(topView)
        topView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        // scroll view
        scrollView.contentView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.contentView.addGestureRecognizer(tap)
        
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        
        // top scrollView
        scrollView.contentView.addSubview(balanceNameLabel)
        layoutCarousel()
        balanceNameLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        scrollView.contentView.addSubview(valueLabel)
        valueLabel.autoPinEdge(.top, to: .bottom, of: balanceNameLabel, withOffset: 5)
        valueLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        scrollView.contentView.addSubview(whiteView)
        whiteView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        whiteView.autoPinEdge(.top, to: .bottom, of: valueLabel, withOffset: 40)
        
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
        convertLogoView.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(changeMode))
        convertLogoView.addGestureRecognizer(tap2)
        
        scrollView.contentView.addSubview(convertLogoView)
        convertLogoView.autoPinEdge(.top, to: .top, of: whiteView, withOffset: -20)
        convertLogoView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // Buy container
        layoutBuyContainer()
        
        // convert view
        layoutConvertView()
        
        // rate label
        whiteView.addSubview(rateLabel)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(getBuyPrice))
        rateLabel.addGestureRecognizer(tap3)
        
        rateLabel.autoPinEdge(.top, to: .bottom, of: convertContainer, withOffset: 20)
        rateLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // pin bottom
        rateLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        
        // config topView
        topView.autoPinEdge(.bottom, to: .top, of: whiteView, withOffset: 25)
        
        // layout bottom
        layoutBottom()
    }
    
    func layoutCarousel() {
        balanceNameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
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
        
        buyContainer.addSubview(buyBalanceLabel)
        buyBalanceLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        buyBalanceLabel.autoPinEdge(.top, to: .bottom, of: balanceLabel, withOffset: 2)
        buyBalanceLabel.autoPinEdge(.leading, to: .trailing, of: buyNameLabel, withOffset: 10)
        layoutTrailingOfBuyContainer()
        
        balanceLabel.autoPinEdge(.trailing, to: .trailing, of: buyBalanceLabel)
    }
    
    func layoutTrailingOfBuyContainer() {
        buyBalanceLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
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
    
    func layoutBottom() {
        let warningLabel = UILabel.with(textSize: 12, weight: .medium, textColor: .a5a7bd, numberOfLines: 0, textAlignment: .center)
        warningLabel.attributedText = NSMutableAttributedString()
            .text("transfer time takes up to".localized().uppercaseFirst, size: 12, weight: .medium, color: .a5a7bd)
            .text(" 5-30 " + "minutes".localized().uppercaseFirst, size: 12, weight: .medium, color: .appMainColor)

        view.addSubview(warningLabel)
        warningLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        warningLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        
        // convertButton
        convertButton.addTarget(self, action: #selector(convertButtonDidTouch), for: .touchUpInside)
        
        view.addSubview(convertButton)
        convertButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        convertButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        convertButton.autoPinEdge(.top, to: .bottom, of: warningLabel, withOffset: 20)
        
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: convertButton, attribute: .bottom, multiplier: 1.0, constant: 16)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
        
        scrollView.autoPinEdge(.bottom, to: .top, of: warningLabel)
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
            .subscribe(onNext: { (balances) in
                self.setUp(with: balances)
            })
            .disposed(by: disposeBag)
        
        UIResponder.isKeyboardShowed
            .filter {$0}
            .subscribe(onNext: { _ in
                DispatchQueue.main.async {
                    self.scrollView.scrollsToBottom()
                }
            })
            .disposed(by: disposeBag)
        
        // textfields
        sellTextField.rx.text.orEmpty
            .skip(1)
            .map {NumberFormatter().number(from: $0)?.doubleValue ?? 0}
            .map {self.buyValue(fromSellValue: $0)}
            .map {self.stringFromNumber($0)}
            .subscribe(onNext: { (text) in
                self.buyTextField.text = text
            })
            .disposed(by: disposeBag)
        
        buyTextField.rx.text.orEmpty
            .skip(1)
            .map {NumberFormatter().number(from: $0)?.doubleValue ?? 0}
            .map {self.sellValue(fromBuyValue: $0)}
            .map {self.stringFromNumber($0)}
            .subscribe(onNext: { (text) in
                self.sellTextField.text = text
            })
            .disposed(by: disposeBag)
        
        // price
        viewModel.buyPriceLoadingState
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (state) in
                switch state {
                case .loading:
                    self?.rateLabel.showLoader()
                    self?.rateLabel.isUserInteractionEnabled = false
                case .finished:
                    self?.rateLabel.hideLoader()
                    self?.rateLabel.isUserInteractionEnabled = false
                case .error(let error):
                    #if !APP_STORE
                        self?.showError(error)
                    #endif
                    self?.rateLabel.hideLoader()
                    self?.rateLabel.attributedText = NSMutableAttributedString()
                        .text("could not get price".localized().uppercaseFirst + ". ", size: 12, weight: .medium, color: .red)
                        .text("retry".localized().uppercaseFirst + "?", size: 12, weight: .medium, color: .appMainColor)
                    self?.rateLabel.isUserInteractionEnabled = true
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.price
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.setUpPrice()
            })
            .disposed(by: disposeBag)
        
        // convert button
        Observable.merge(
            sellTextField.rx.text.orEmpty.map {_ in ()},
            buyTextField.rx.text.orEmpty.skip(1).map {_ in ()}
        )
            .map { _ in self.shouldEnableConvertButton()}
            .bind(to: convertButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func buyValue(fromSellValue value: Double) -> Double {
        fatalError("Must override")
    }
    
    func sellValue(fromBuyValue value: Double) -> Double {
        fatalError("Must override")
    }
    
    func shouldEnableConvertButton() -> Bool {
        fatalError("Must override")
    }
    
    private func setUp(with balances: [ResponseAPIWalletGetBalance]) {
        if let balance = balances.first(where: {$0.symbol == "CMN"}) {
            communBalance = balance
        }
        
        currentBalance = balances.first(where: {$0.symbol == currentSymbol}) ?? balances.first(where: {$0.symbol != "CMN"})
    }
    
    func setUpCommunBalance() {
        
    }
    
    func setUpCurrentBalance() {
        getBuyPrice()
    }
    
    func setUpPrice() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = true
        showNavigationBar(false, animated: true, completion: nil)
        self.navigationController?.navigationBar.setTitleFont(.boldSystemFont(ofSize: 17), color: .white)
        
        // hide bottom tabbar
        tabBarController?.tabBar.isHidden = true
        let tabBarVC = (tabBarController as? TabBarVC)
        tabBarVC?.setTabBarHiden(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let tabBarVC = (tabBarController as? TabBarVC)
        tabBarVC?.setTabBarHiden(false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        whiteView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 25)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func changeMode() {
        guard var viewControllers = navigationController?.viewControllers else { return }

        // Pop sourceViewController
        _ = viewControllers.popLast()

        // Push targetViewController
        let vc: UIViewController
        
        if self is WalletSellCommunVC {
            vc = WalletBuyCommunVC(symbol: currentBalance?.symbol)
        } else {
            vc = WalletSellCommunVC(symbol: currentBalance?.symbol)
        }
        
        viewControllers.append(vc)

        navigationController?.setViewControllers(viewControllers, animated: false)
    }
    
    @objc func getBuyPrice() {
        guard let balance = currentBalance else {return}
        viewModel.getBuyPrice(symbol: balance.symbol)
    }
    
    @objc func convertButtonDidTouch() {
        // TODO: - Convert
    }
    
    // MARK: - Helpers
    func stringFromNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = (number < 1000) ? 4 : 2
        return formatter.string(from: number as NSNumber) ?? "0"
    }
}

extension WalletConvertVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text != "" || string != "" {
            let res = (textField.text ?? "") + string
            let formatter = NumberFormatter()
            return formatter.number(from: res) != nil
        }
        return true
    }
}
