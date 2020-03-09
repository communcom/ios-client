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
        .appMainColor
    }
    
    var historyItem: ResponseAPIWalletGetTransferHistoryItem?
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(axis: .horizontal)
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
    lazy var leftTextField = createTextField()
    lazy var convertBuyLabel = UILabel.with(text: "Buy", textSize: 12, weight: .medium, textColor: .a5a7bd)
    lazy var rightTextField: UITextField = {
        let textField = createTextField()
        textField.isEnabled = false
        return textField
    }()
    
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
    
    lazy var errorLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: .red, textAlignment: .center)
    lazy var rateLabel = UILabel.with(text: "Rate: ", textSize: 12, weight: .medium, textAlignment: .center)
    
    lazy var convertButton = CommunButton.default(height: .adaptive(height: 50.0), label: "convert".localized().uppercaseFirst, isHuggingContent: false, isDisabled: true)
    
    
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
        
        // error Label
        whiteView.addSubview(errorLabel)
        errorLabel.autoPinEdge(.top, to: .bottom, of: convertContainer, withOffset: 8)
        errorLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        errorLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        errorLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        
        // rate label
        whiteView.addSubview(rateLabel)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(getBuyPrice))
        rateLabel.addGestureRecognizer(tap3)
        
        rateLabel.autoPinEdge(.top, to: .bottom, of: errorLabel, withOffset: 12)
        rateLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // pin bottom
        rateLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        
        // config topView
        topView.autoPinEdge(.bottom, to: .top, of: whiteView, withOffset: 25)
        
        // layout bottom
        layoutBottom()
    }
    
    override func bind() {
        super.bind()
        
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
        
        // buy price
        bindBuyPrice()
        
        // sell price
        bindSellPrice()
        
        // price loading state
        viewModel.priceLoadingState
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (state) in
                switch state {
                case .loading:
                    if !(self?.rightTextField.isFirstResponder ?? false) {
                        self?.rightTextField.showLoader()
                    }
                    
                    if !(self?.leftTextField.isFirstResponder ?? false) {
                        self?.leftTextField.showLoader()
                    }
                    
                    self?.convertButton.isDisabled = true
//                    self?.convertButton.isEnabled = false
                
                case .finished:
                    self?.rightTextField.hideLoader()
                    self?.leftTextField.hideLoader()
                    
                    self?.convertButton.isDisabled = !(self?.shouldEnableConvertButton() ?? false)
//                    self?.convertButton.isEnabled = self?.shouldEnableConvertButton() ?? false
                
                case .error:
                    self?.rightTextField.hideLoader()
                    self?.leftTextField.hideLoader()
                    
                    self?.convertButton.isDisabled = true
//                    self?.convertButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
        
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
        
        viewModel.rate
            .subscribe(onNext: { [weak self] _ in
                self?.bindRate()
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = true
        showNavigationBar(false, animated: true, completion: nil)
        self.navigationController?.navigationBar.setTitleFont(.boldSystemFont(ofSize: 17), color: .white)
        
        setTabBarHidden(true)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setTabBarHidden(false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        whiteView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 25)
    }
    
    // MARK: - Layout
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
        
        firstView.addSubview(leftTextField)
        leftTextField.autoPinEdge(.top, to: .bottom, of: convertSellLabel, withOffset: 8)
        leftTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16), excludingEdge: .top)
        
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
        
        secondView.addSubview(rightTextField)
        rightTextField.autoPinEdge(.top, to: .bottom, of: convertBuyLabel, withOffset: 8)
        rightTextField.autoPinEdge(.leading, to: .trailing, of: equalLabel)
        rightTextField.autoPinBottomAndTrailingToSuperView(inset: 10, xInset: 16)
        
        convertContainer.addArrangedSubview(secondView)
    }
    
    func layoutBottom() {
        // convertButton
        convertButton.addTarget(self, action: #selector(convertButtonDidTouch), for: .touchUpInside)
        
        view.addSubview(convertButton)
        convertButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        convertButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: convertButton, attribute: .bottom, multiplier: 1.0, constant: 16)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
        
        scrollView.autoPinEdge(.bottom, to: .top, of: convertButton)
    }
        
    // MARK: - Updating
    private func setUp(with balances: [ResponseAPIWalletGetBalance]) {
        if let balance = balances.first(where: {$0.symbol == Config.defaultSymbol}) {
            communBalance = balance
        }
        
        currentBalance = balances.first(where: {$0.symbol == currentSymbol}) ?? balances.first(where: {$0.symbol != Config.defaultSymbol})
    }
    
    func setUpCommunBalance() {
        
    }
    
    func setUpCurrentBalance() {
        getBuyPrice()
        getRate()
    }
    
    func getRate() {
        guard let balance = currentBalance else {return}
        viewModel.getRate(symbol: balance.symbol)
    }
    
    func setUpBuyPrice() {
        fatalError("Must override")
    }
    
    func setUpSellPrice() {
        fatalError("Must override")
    }
    
    // MARK: - Computing
    func shouldEnableConvertButton() -> Bool {
        fatalError("Must override")
    }
    
    func checkValues() -> Bool {
        guard errorLabel.text == nil else {
            self.hintView?.display(inPosition: convertButton.frame.origin, withType: .error(errorLabel.text!), completion: {})
            return false
        }
        
        guard convertButton.isDisabled, let amount = leftTextField.text, amount.isEmpty else { return true }
        
        self.hintView?.display(inPosition: convertButton.frame.origin, withType: .enterAmount, completion: {})
        
        return false
    }

    
    // MARK: - Actions
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func changeMode() {
        view.endEditing(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard var viewControllers = self.navigationController?.viewControllers else { return }

            // Pop sourceViewController
            _ = viewControllers.popLast()

            // Push targetViewController
            let vc: UIViewController
            
            if self is WalletSellCommunVC {
                vc = WalletBuyCommunVC(balances: self.viewModel.items.value, symbol: self.currentBalance?.symbol)
            } else {
                vc = WalletSellCommunVC(balances: self.viewModel.items.value, symbol: self.currentBalance?.symbol)
            }
            
            viewControllers.append(vc)

            self.navigationController?.setViewControllers(viewControllers, animated: false)
        }
    }
    
    @objc func getBuyPrice() {
        fatalError("Must override")
    }
    
    @objc func getSellPrice() {
        fatalError("Must override")
    }
    
    @objc func convertButtonDidTouch() {
        view.endEditing(true)
    }
    
    @objc func pointsListButtonDidTouch() {
        let vc = BalancesVC { balance in
            self.currentBalance = balance
        }
        
        let nc = BaseNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
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
        historyItem = nil
        
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
        
        if updatedText.starts(with: "0") && !updatedText.starts(with: "0.") {
            updatedText = currentText.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
            textField.text = updatedText
        }
        
        return isANumber
    }
}
