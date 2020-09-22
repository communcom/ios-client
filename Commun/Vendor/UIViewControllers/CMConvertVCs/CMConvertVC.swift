//
//  CMConvertVC.swift
//  Commun
//
//  Created by Chung Tran on 9/22/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

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


