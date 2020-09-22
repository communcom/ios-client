//
//  CMSendPointsVC.swift
//  Commun
//
//  Created by Chung Tran on 9/22/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class CMConverterVC: BaseViewController, UITextFieldDelegate {
    // MARK: - Properties
    override var preferredStatusBarStyle: UIStatusBarStyle {.lightContent}
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.normal(translucent: true, backgroundColor: .clear, font: .boldSystemFont(ofSize: 17), textColor: .appWhiteColor)}
    override var shouldHideTabBar: Bool {true}
    var topColor: UIColor { .appMainColor }
    
    // MARK: - Subviews
    lazy var scrollView: ContentHuggingScrollView = {
        let scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
        scrollView.contentView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.contentView.addGestureRecognizer(tap)
        return scrollView
    }()
    lazy var topStackView: UIStackView = {
        let stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .center, distribution: .fill)
        stackView.addArrangedSubviews([balanceNameLabel, valueLabel])
        stackView.setCustomSpacing(5, after: balanceNameLabel)
        return stackView
    }()
    lazy var balanceNameLabel = UILabel.with(textSize: 17, weight: .semibold, textColor: .white)
    lazy var valueLabel = UILabel.with(textSize: 30, weight: .semibold, textColor: .white)
    lazy var whiteView = UIView(backgroundColor: .appWhiteColor)
    lazy var stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    
    lazy var actionButton: CommunButton = {
        let button = CommunButton.default(height: 50, label: "convert".localized().uppercaseFirst, isHuggingContent: false, isDisabled: true)
        button.addTarget(self, action: #selector(actionButtonDidTouch), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavBarBackButton(tintColor: .white)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        whiteView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 25)
    }
    
    override func setUp() {
        super.setUp()
        // backgroundColor
        let topView = UIView(backgroundColor: topColor)
        view.addSubview(topView)
        topView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        // scroll view
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        
        // top scrollView
        scrollView.contentView.addSubview(topStackView)
        topStackView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        topStackView.autoAlignAxis(toSuperviewAxis: .vertical)

        scrollView.contentView.addSubview(whiteView)
        whiteView.autoPinEdge(.top, to: .bottom, of: topStackView, withOffset: 40)
        whiteView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        whiteView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 40, left: 16, bottom: 0, right: 16))
        
        // config topView
        topView.autoPinEdge(.bottom, to: .top, of: whiteView, withOffset: 25)
        
        // action button
        view.addSubview(actionButton)
        actionButton.autoPinEdge(.top, to: .bottom, of: scrollView)
        actionButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        actionButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        actionButton.autoPinBottomToSuperViewSafeAreaAvoidKeyboard(inset: 16)
    }
    
    override func bind() {
        super.bind()
        bindScrollView()
    }
    
    // MARK: - Actions
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func actionButtonDidTouch() {
        view.endEditing(true)
    }
    
    func bindScrollView() {
        let keyboardOnOffset: CGFloat = 161.5
        var additionalBottomInset: CGFloat?
        switch UIDevice.current.screenType {
        case .iPhones_6_6s_7_8:
            additionalBottomInset = 51
        case .iPhones_6Plus_6sPlus_7Plus_8Plus:
            additionalBottomInset = 110.5
        case .iPhones_X_XS, .iPhone_11Pro:
            additionalBottomInset = 97.5
        case .iPhone_XR_11:
            additionalBottomInset = 171
        case .iPhone_XSMax_ProMax:
            additionalBottomInset = 171.5
        case .unknown:
            break
        default:
            break
        }
        
        // handle keyboard
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe { _ in
                DispatchQueue.main.async {
                    if let additionalBottomInset = additionalBottomInset {
                        self.scrollView.contentInset.bottom = additionalBottomInset
                    }
                    let bottomOffset = CGPoint(x: 0, y: keyboardOnOffset)
                    self.scrollView.setContentOffset(bottomOffset, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification)
            .subscribe { _ in
                DispatchQueue.main.async {
                    let bottomOffset = CGPoint(x: 0, y: keyboardOnOffset)
                    self.scrollView.setContentOffset(bottomOffset, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidHideNotification)
            .subscribe { _ in
                if additionalBottomInset != nil {
                    self.scrollView.contentInset.bottom = 0
                }
            }
            .disposed(by: disposeBag)
        
        scrollView.rx.contentOffset
            .map {$0.y}
            .subscribe(onNext: { (offsetY) in
                    
                let titleLabel = UILabel.with(text: "convert".localized().uppercaseFirst, textSize: 15, weight: .semibold, textColor: .white, numberOfLines: 2, textAlignment: .center)
                
                if offsetY >= self.view.safeAreaInsets.top + CGFloat.adaptive(height: 6) {
                    if offsetY >= self.view.safeAreaInsets.top + CGFloat.adaptive(height: 33) {
                        titleLabel.attributedText = NSMutableAttributedString()
                            .text(self.balanceNameLabel.text ?? "", size: 14, weight: .semibold, color: .white)
                            .text("\n")
                            .text(self.valueLabel.text ?? "", size: 16, weight: .semibold, color: .white)
                        self.balanceNameLabel.alpha = 0
                        self.valueLabel.alpha = 0
                    } else {
                        titleLabel.text = self.balanceNameLabel.text
                        self.balanceNameLabel.alpha = 0
                        self.valueLabel.alpha = 1
                    }
                } else {
                    self.balanceNameLabel.alpha = 1
                    self.valueLabel.alpha = 1
                }
                self.navigationItem.titleView = titleLabel
                self.view.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
    }
    
    func createTextField() -> UITextField {
        let textField = UITextField(backgroundColor: .clear)
        textField.placeholder = "0"
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 17, weight: .semibold)
        textField.setPlaceHolderTextColor(.appGrayColor)
        textField.keyboardType = .decimalPad
        textField.delegate = self
        return textField
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // if input comma (or dot)
        if textField.text?.isEmpty == true, string == Locale.current.decimalSeparator {
            textField.text = "0\(Locale.current.decimalSeparator ?? ".")"
            return false
        }
        
        // if deleting
        if string.isEmpty { return true }
        
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        var updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // check if newText is a Number
        let formatter = NumberFormatter()
        let isANumber = formatter.number(from: updatedText) != nil
        
        if updatedText.starts(with: "0") && !updatedText.starts(with: "0\(Locale.current.decimalSeparator ?? ".")") {
            updatedText = currentText.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
            textField.text = updatedText
        }
        
        return isANumber
    }
}

class CMConvertVC: CMConverterVC {
    // MARK: - Properties
    var historyItem: ResponseAPIWalletGetTransferHistoryItem?
    let viewModel = WalletConvertViewModel()
    var currentSymbol: String?
    var currentBalance: ResponseAPIWalletGetBalance? {
        didSet { setUpCurrentBalance() }
    }
    
    var communBalance: ResponseAPIWalletGetBalance? {
        didSet { setUpCommunBalance() }
    }
    
    // MARk: - Subviews
    lazy var buyLogoImageView = MyAvatarImageView(size: 40)
    lazy var buyNameLabel = UILabel.with(textSize: 15, weight: .medium, numberOfLines: 2, textAlignment: .left)
    lazy var buyBalanceLabel = UILabel.with(textSize: 15, weight: .medium, numberOfLines: 2, textAlignment: .right)
    
    lazy var convertSellLabel = UILabel.with(text: "Sell", textSize: 12, weight: .medium, textColor: .appGrayColor)
    lazy var leftTextField = createTextField()
    lazy var convertBuyLabel = UILabel.with(text: "Buy", textSize: 12, weight: .medium, textColor: .appGrayColor)
    lazy var rightTextField: UITextField = {
        let textField = createTextField()
        textField.isEnabled = false
        return textField
    }()
    lazy var errorLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: .red, textAlignment: .center)
    lazy var rateLabel: UILabel = {
        let rateLabel = UILabel.with(text: "Rate: ", textSize: 12, weight: .medium, textAlignment: .center)
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(getBuyPrice))
        rateLabel.addGestureRecognizer(tap3)
        return rateLabel
    }()
    var convertButton: CommunButton { actionButton }
    
    // MARK: - Initializers
    init(balances: [ResponseAPIWalletGetBalance], symbol: String? = nil, historyItem: ResponseAPIWalletGetTransferHistoryItem? = nil) {
        currentSymbol = symbol == Config.defaultSymbol ? nil : symbol
        viewModel.items.accept(balances)
        
        if let history = historyItem {
            self.historyItem = history
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        // change converter
        let changeModeButton: UIView = {
            let view = UIView(width: 40, height: 40, backgroundColor: .appMainColor, cornerRadius: 20)
            view.borderWidth = 2
            view.borderColor = .white
            let imageView = UIImageView(width: 23, height: 19, imageNamed: "wallet-convert")
            view.addSubview(imageView)
            imageView.autoAlignAxis(toSuperviewAxis: .vertical)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(changeMode))
            view.addGestureRecognizer(tap)
            return view
        }()
        
        view.addSubview(changeModeButton)
        changeModeButton.autoPinEdge(.bottom, to: .top, of: whiteView, withOffset: 20)
        changeModeButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // buy container
        let buyContainer: UIView = {
            let view = borderedView()
            
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyContainerDidTouch)))
            let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
            view.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
            
            stackView.addArrangedSubviews([buyLogoImageView, buyNameLabel, buyBalanceLabel])
            
            if !(self is CMBuyCommunVC) {
                let dropdownButton = UIButton.circleGray(imageName: "drop-down")
                dropdownButton.isUserInteractionEnabled = false
                stackView.addArrangedSubview(dropdownButton)
            }
            return view
        }()
        
        stackView.addArrangedSubview(buyContainer)
        
        // convert container
        let convertContainer: UIStackView = {
            let stackView = UIStackView(axis: .horizontal, spacing: 10)
            let firstView: UIView = borderedView()
            firstView.addSubview(convertSellLabel)
            convertSellLabel.autoPinTopAndLeadingToSuperView(inset: 10, xInset: 16)
            
            firstView.addSubview(leftTextField)
            leftTextField.autoPinEdge(.top, to: .bottom, of: convertSellLabel, withOffset: 8)
            leftTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16), excludingEdge: .top)
            
            stackView.addArrangedSubview(firstView)
            
            let secondView = borderedView()
            
            secondView.addSubview(convertBuyLabel)
            convertBuyLabel.autoPinTopAndLeadingToSuperView(inset: 10, xInset: 16)
            
            let equalLabel = UILabel.with(text: "= ", textSize: 17, weight: .semibold, textColor: .appGrayColor)
            equalLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            secondView.addSubview(equalLabel)
            equalLabel.autoPinEdge(.top, to: .bottom, of: convertBuyLabel, withOffset: 8)
            equalLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            
            secondView.addSubview(rightTextField)
            rightTextField.autoPinEdge(.top, to: .bottom, of: convertBuyLabel, withOffset: 8)
            rightTextField.autoPinEdge(.leading, to: .trailing, of: equalLabel)
            rightTextField.autoPinBottomAndTrailingToSuperView(inset: 10, xInset: 16)
            
            stackView.addArrangedSubview(secondView)
            return stackView
        }()
        
        stackView.addArrangedSubview(convertContainer)
        
        stackView.addArrangedSubviews([
            errorLabel,
            rateLabel
        ])
        
        stackView.setCustomSpacing(8, after: convertContainer)
        stackView.setCustomSpacing(12, after: errorLabel)
        
        errorLabel.isHidden = true
    }
    
    private func setUp(with balances: [ResponseAPIWalletGetBalance]) {
        if let balance = balances.first(where: {$0.symbol == Config.defaultSymbol}) {
            communBalance = balance
        }
        
        currentBalance = balances.first(where: {$0.symbol == currentSymbol}) ?? balances.first(where: {$0.symbol != Config.defaultSymbol})
    }
    
    func setUpRate() {
        
    }
    
    func setUpCommunBalance() {
        
    }
    
    func setUpCurrentBalance() {
        getBuyPrice()
        getRate()
    }
    
    func setUpBuyPrice() {
        fatalError("Must override")
    }
    
    func setUpSellPrice() {
        fatalError("Must override")
    }
    
    // MARK: - Binding
    override func bind() {
        super.bind()
        bindState()
        bindItems()
        bindBuyPrice()
        bindSellPrice()
        bindError()
        bindRate()
    }
    
    func bindState() {
        viewModel.state
            .subscribe(onNext: { (state) in
                switch state {
                case .error(error: let error):
                    #if !APPSTORE
                    self.showError(error)
                    #endif
                    self.view.showErrorView {
                        self.view.hideErrorView()
                        self.viewModel.reload()
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // price loading state
        viewModel.priceLoadingState
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (state) in
                switch state {
                case .loading:
                    if !(self?.rightTextField.isFirstResponder ?? false) {
                        self?.rightTextField.hideLoader()
                        self?.rightTextField.showLoader()
                    }
                    
                    if !(self?.leftTextField.isFirstResponder ?? false) {
                        self?.leftTextField.hideLoader()
                        self?.leftTextField.showLoader()
                    }
                    
                    self?.actionButton.isDisabled = true
                    //                    self?.convertButton.isEnabled = false
                    
                case .finished:
                    self?.rightTextField.hideLoader()
                    self?.leftTextField.hideLoader()
                    
                    self?.actionButton.isDisabled = !(self?.shouldEnableConvertButton() ?? false)
                    //                    self?.convertButton.isEnabled = self?.shouldEnableConvertButton() ?? false
                    
                case .error:
                    self?.rightTextField.hideLoader()
                    self?.leftTextField.hideLoader()
                    
                    self?.actionButton.isDisabled = true
                    //                    self?.convertButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindItems() {
        viewModel.items
            .subscribe(onNext: { (balances) in
                self.setUp(with: balances)
            })
            .disposed(by: disposeBag)
    }
    
    func bindBuyPrice() {
        fatalError("Must override")
    }
    
    func bindSellPrice() {
        fatalError("Must override")
    }
    
    func bindRate() {
        viewModel.rate
            .subscribe(onNext: { [weak self] _ in
                self?.setUpRate()
            })
            .disposed(by: disposeBag)
    }
    
    func bindError() {
        // errorLabel
        viewModel.errorSubject
            .subscribe(onNext: {[weak self] (error) in
                guard self?.historyItem == nil else { return }
                
                switch error {
                case .other(let error):
                    self?.errorLabel.text = "Error: " + error.localizedDescription
                
                case .insufficientFunds:
                    self?.errorLabel.text = "Error: Insufficient funds"
                
                default:
                    self?.errorLabel.text = nil
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - View builder
    private func borderedView() -> UIView {
        let view = UIView(cornerRadius: 10)
        view.borderColor = #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9803921569, alpha: 1).inDarkMode(.white)
        view.borderWidth = 1
        return view
    }
    
    // MARK: - Helpers
    func shouldEnableConvertButton() -> Bool {
        fatalError("Must override")
    }
    
    func getRate() {
        guard let balance = currentBalance else {return}
        viewModel.getRate(symbol: balance.symbol)
    }
    
    @objc func getBuyPrice() {
        fatalError("Must override")
    }
    
    @objc func getSellPrice() {
        fatalError("Must override")
    }
    
    func checkValues() -> Bool {
        guard errorLabel.text == nil else {
            self.hintView?.display(inPosition: actionButton.frame.origin, withType: .error(errorLabel.text!), completion: {})
            return false
        }
        
        guard actionButton.isDisabled, let amount = leftTextField.text, amount.isEmpty else { return true }
        
        self.hintView?.display(inPosition: actionButton.frame.origin, withType: .enterAmount, completion: {})
        
        return false
    }
    
    func stringFromNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = (number < 1000) ? 4 : 2
        return formatter.string(from: number as NSNumber) ?? "0"
    }
    
    // MARK: - Actions
    func showCheck(transaction: Transaction) {
        let completedVC = TransactionCompletedVC(transaction: transaction)
        self.show(completedVC, sender: nil)
    }
    
    @objc func changeMode() {
        view.endEditing(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard var viewControllers = self.navigationController?.viewControllers else { return }

            // Pop sourceViewController
            _ = viewControllers.popLast()

            // Push targetViewController
            let vc: CMConvertVC
            
            if self is CMSellCommunVC {
                vc = CMBuyCommunVC(balances: self.viewModel.items.value, symbol: self.currentBalance?.symbol)
            } else {
                vc = CMSellCommunVC(balances: self.viewModel.items.value, symbol: self.currentBalance?.symbol)
            }
            
            viewControllers.append(vc)

            self.navigationController?.setViewControllers(viewControllers, animated: false)
        }
    }
    
    @objc func buyContainerDidTouch() {
        let vc = BalancesVC(canChooseCommun: false) { (balance) in
            self.currentBalance = balance
        }
        let nc = SwipeNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    // MARK: - TextField delegate
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        historyItem = nil
        
        return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
}

class CMSellCommunVC: CMConvertVC {
    override func setUp() {
        super.setUp()
        balanceNameLabel.text = "Commun"
        convertSellLabel.text = "sell".localized().uppercaseFirst + " Commun"
        
        let communLogo = UIView.transparentCommunLogo(size: 50)
        topStackView.insertArrangedSubview(communLogo, at: 0)
        topStackView.setCustomSpacing(20, after: communLogo)
    }
    
    override func setUpCommunBalance() {
        super.setUpCommunBalance()
        guard let balance = communBalance else {return}
        
        valueLabel.text = balance.balanceValue.currencyValueFormatted
    }
    
    override func setUpCurrentBalance() {
        super.setUpCurrentBalance()
        guard let balance = currentBalance else {return}
        
        buyLogoImageView.setAvatar(urlString: balance.logo)
        buyNameLabel.attributedText = NSMutableAttributedString()
            .text("buy".localized().uppercaseFirst, size: 12, color: .appGrayColor)
            .text("\n")
            .text(balance.name ?? balance.symbol, size: 15, weight: .semibold)
        buyBalanceLabel.attributedText = NSMutableAttributedString()
            .text("balance".localized().uppercaseFirst, size: 12, color: .appGrayColor)
            .text("\n")
            .text(balance.balanceValue.currencyValueFormatted, size: 15, weight: .semibold)
        convertBuyLabel.text = "buy".localized().uppercaseFirst + " \(balance.name ?? balance.symbol)"
    }
    
    override func setUpBuyPrice() {
        if let history = historyItem, !leftTextField.isFirstResponder {
            rightTextField.text = stringFromNumber(history.meta.exchangeAmount!)
        } else {
            rightTextField.text = stringFromNumber(viewModel.buyPrice.value)
        }
        
        convertButton.isDisabled = !shouldEnableConvertButton()
    }
    
    override func setUpSellPrice() {
        if let history = historyItem, !leftTextField.isFirstResponder {
            leftTextField.text = stringFromNumber(history.quantityValue)
        } else if viewModel.sellPrice.value > 0 {
            leftTextField.text = stringFromNumber(viewModel.sellPrice.value)
        }
        
        convertButton.isDisabled = !shouldEnableConvertButton()
    }
    
    override func setUpRate() {
        super.setUpRate()
        rateLabel.attributedText = NSMutableAttributedString()
            .text("rate".localized().uppercaseFirst + ": 10 CMN = \(viewModel.rate.value.currencyValueFormatted) \(currentBalance?.symbol ?? "")", size: 12, weight: .medium)
    }
    
    // MARK: - Binding
    override func bindBuyPrice() {
        leftTextField.rx.text.orEmpty
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .map {NumberFormatter().number(from: $0)?.doubleValue ?? 0}
            .subscribe(onNext: { (value) in
                if value == 0 {
                    self.viewModel.currentBuyPriceSymbol = nil
                    self.viewModel.currentBuyPriceQuantity = nil
                    self.viewModel.priceLoadingState.accept(.finished)
                    self.viewModel.buyPrice.accept(0)
                    return
                }
                self.getBuyPrice()
            })
            .disposed(by: disposeBag)
        
        viewModel.buyPrice
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.setUpBuyPrice()
            })
            .disposed(by: disposeBag)
    }
    
    override func bindSellPrice() {
        rightTextField.rx.text.orEmpty
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .map {NumberFormatter().number(from: $0)?.doubleValue ?? 0}
            .subscribe(onNext: { (value) in
                if value == 0 {
                    self.viewModel.currentSellPriceQuantity = nil
                    self.viewModel.priceLoadingState.accept(.finished)
                    self.viewModel.sellPrice.accept(0)
                    return
                }
                self.getSellPrice()
            })
            .disposed(by: disposeBag)
        
        viewModel.sellPrice
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.setUpSellPrice()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helpers
    override func shouldEnableConvertButton() -> Bool {
        guard let sellAmount = NumberFormatter().number(from: self.leftTextField.text ?? "0")?.doubleValue else { return false }
        guard let communBalance = self.communBalance else { return false }
        guard sellAmount > 0 else { return false }
        
        if sellAmount > communBalance.balanceValue {
            viewModel.errorSubject.accept(.insufficientFunds)
            return false
        }
        
        return true
    }
    
    override func getBuyPrice() {
        guard let balance = currentBalance,
            let value = NumberFormatter().number(from: leftTextField.text ?? "")?.doubleValue,
            value > 0
        else {return}
        viewModel.getBuyPrice(symbol: balance.symbol, quantity: "\(value) CMN")
    }
    
    override func getSellPrice() {
        guard let balance = currentBalance,
            let value = NumberFormatter().number(from: rightTextField.text ?? "")?.doubleValue,
            value > 0
        else { return }
        viewModel.getSellPrice(quantity: "\(value) \(balance.symbol)")
    }
    
    // MARK: - Actions
    override func actionButtonDidTouch() {
        guard checkValues() else { return }
        
        super.actionButtonDidTouch()
        
        guard var balance = currentBalance,
            var communBalance = communBalance,
            let value = NumberFormatter().number(from: leftTextField.text ?? "")?.doubleValue
        else { return }
        
        let expectedValue = NumberFormatter().number(from: rightTextField.text ?? "")?.doubleValue
        
        showIndetermineHudWithMessage("buying".localized().uppercaseFirst + " \(balance.symbol)")
        BlockchainManager.instance.buyPoints(communNumber: value, pointsCurrencyName: balance.symbol)
            .flatMapCompletable({ (transactionId) -> Completable in
                self.hideHud()
                
                if let expectedValue = expectedValue {
                    let newValue = expectedValue + balance.balanceValue
                    balance.balance = String(newValue)
                    balance.isWaitingForTransaction = true
                    balance.notifyChanged()
                    
                    let newCMNValue = communBalance.balanceValue - value
                    communBalance.balance = String(newCMNValue)
                    communBalance.isWaitingForTransaction = true
                    communBalance.notifyChanged()
                }

                let symbol: Symbol = Symbol(sell: Config.defaultSymbol, buy: balance.symbol)

                let transaction = Transaction(amount: CGFloat(value * self.viewModel.rate.value / 10),
                                              actionType: "sell",
                                              symbol: symbol,
                                              operationDate: Date())

                self.showCheck(transaction: transaction)

                self.hideHud()
                
                return RestAPIManager.instance.waitForTransactionWith(id: transactionId)
            })
            .subscribe(onCompleted: {
                balance.isWaitingForTransaction = false
                balance.notifyChanged()
                
                communBalance.isWaitingForTransaction = false
                communBalance.notifyChanged()
            }) { [weak self] (error) in
                self?.hideHud()
                self?.showError(error)
            }
            .disposed(by: disposeBag)
    }
}

class CMBuyCommunVC: CMConvertVC {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func buyContainerDidTouch() {
        // do nothing
    }
}
