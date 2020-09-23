//
//  CMSendPointsVC.swift
//  Commun
//
//  Created by Chung Tran on 9/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class CMSendPointsVC: CMTransferVC {
    // MARK: - Properties
    override var titleText: String { "send points".localized().uppercaseFirst }
    let viewModel = CMSendPointsViewModel()
    
    var burningPercentage: CGFloat { viewModel.selectedBalance.value?.symbol != "CMN" ? 0.1: 0 }
    var enteredAmount: Double { amountTextField.text?.toDouble() ?? 0 }
    var memo: String { viewModel.memo }
    var actionName: String { "send" }
    
    // MARK: - Subviews
    lazy var walletCarouselWrapper = WalletCarouselWrapper(height: 50)
    lazy var receiverAvatarImageView = MyAvatarImageView(size: 40)
    lazy var receiverNameLabel = UILabel.with(text: "receiver", textSize: 15, weight: .semibold)
    lazy var greenTick: UIButton = {
        let button = UIButton.circle(size: 24, backgroundColor: .clear, tintColor: .appWhiteColor, imageName: "icon-select-user-grey-cyrcle-default", imageEdgeInsets: .zero)
        button.setImage(UIImage(named: "icon-select-user-green-cyrcle-selected"), for: .selected)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    lazy var amountContainer: UIView = {
        let view = borderedView()
        
        let stackView = UIStackView(axis: .vertical, spacing: 8, alignment: .fill, distribution: .fill)
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        
        let amountLabel = UILabel.with(text: "amount".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: .appGrayColor)
        stackView.addArrangedSubviews([amountLabel, amountTextField])
        
        return view
    }()
    lazy var amountTextField: UITextField = {
        let textField = createTextField()
        
        let clearButton: UIButton = {
            let btnView = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            btnView.setImage(UIImage(named: "icon-cancel-grey-cyrcle-default"), for: .normal)
            btnView.imageEdgeInsets = .zero
            btnView.addTarget(self, action: #selector(clearButtonTapped(_:)), for: .touchUpInside)
            return btnView
        }()
        
        textField.rightView = clearButton
        textField.rightViewMode = .whileEditing
        
        return textField
    }()
    lazy var alertLabel = UILabel.with(textSize: 12, weight: .bold, textColor: .appRedColor, numberOfLines: 0)
    
    // MARK: - Initializers
    init(selectedBalanceSymbol: String? = nil, receiver: ResponseAPIContentGetProfile? = nil, history: ResponseAPIWalletGetTransferHistoryItem? = nil) {
        super.init(nibName: nil, bundle: nil)
        defer {
            if let history = history {
                let amount = CGFloat(history.quantityValue)
                amountTextField.text = Double(amount).currencyValueFormatted
            }
            
            viewModel.selectedReceiver.accept(receiver)
            viewModel.balancesVM.items.filter {!$0.isEmpty}.take(1).asSingle()
                .subscribe(onSuccess: { (_) in
                    self.viewModel.selectedBalance.accept(self.viewModel.balances.first(where: {$0.symbol == selectedBalanceSymbol}))
                })
                .disposed(by: disposeBag)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        // add carousel
        topStackView.insertArrangedSubview(walletCarouselWrapper, at: 0)
        topStackView.setCustomSpacing(20, after: walletCarouselWrapper)
        
        setRightBarButton(imageName: "wallet-right-bar-button", tintColor: .white, action: #selector(pointsListButtonDidTouch))
        
        walletCarouselWrapper.scrollingHandler = { index in
            self.viewModel.selectBalanceAtIndex(index: index)
        }
        
        // add receiver container
        let receiverContainer: UIView = {
            let view = borderedView()
            
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseRecipientViewTapped(_:))))
            let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
            view.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
            
            stackView.addArrangedSubviews([receiverAvatarImageView, receiverNameLabel, greenTick])
            
            return view
        }()
        
        stackView.addArrangedSubviews([receiverContainer, amountContainer, alertLabel])
    }
    
    override func bind() {
        super.bind()
        bindState()
        bindBalances()
        bindReceiver()
        bindError()
        bindTextField()
    }
    
    func bindState() {
        viewModel.balancesVM.state
            .subscribe(onNext: {[weak self] state in
                switch state {
                case .loading(let isLoading):
                    self?.setUp(loading: isLoading)
                
                case .listEnded, .listEmpty:
                    self?.setUp(loading: false)
                
                case .error(let error):
                    self?.view.showErrorView(retryAction: {
                        self?.view.hideErrorView()
                        self?.viewModel.reload()
                    })
                    #if !APPSTORE
                        self?.showAlert(title: "Error", message: "\(error)")
                    #endif
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindBalances() {
        viewModel.balancesVM.items
            .subscribe(onNext: { (balances) in
                self.setUp(balances: balances)
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedBalance
            .subscribe(onNext: { (balance) in
                self.setUp(selectedBalance: balance)
            })
            .disposed(by: disposeBag)
    }
    
    func bindReceiver() {
        viewModel.selectedReceiver
            .subscribe(onNext: { (receiver) in
                self.setUp(receiver: receiver)
            })
            .disposed(by: disposeBag)
    }
    
    func bindError() {
        viewModel.error
            .subscribe(onNext: { (error) in
                if let error = error {
                    self.alertLabel.text = error.errorDescription
                    self.amountContainer.borderColor = error.errorDescription != nil ? .appRedColor : self.defaultBorderColor
                } else {
                    self.alertLabel.text = nil
                    self.amountContainer.borderColor = self.defaultBorderColor
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindTextField() {
        Observable<Void>.merge(
            viewModel.selectedBalance.map {_ in ()},
            amountTextField.rx.text.orEmpty.map {_ in ()},
            viewModel.selectedReceiver.map {_ in ()}
        )
            .subscribe(onNext: { _ in
                let canSend = self.viewModel.check(amount: self.enteredAmount)
                self.actionButton.isDisabled = !canSend
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.selectedBalance,
            amountTextField.rx.text.orEmpty
        )
            .subscribe(onNext: { _ in
                self.configureActionButton()
            })
            .disposed(by: disposeBag)
    }
    
    func configureActionButton() {
        // configure send button
        let symbol = viewModel.selectedBalance.value?.symbol ?? "points".localized().uppercaseFirst
        let title = NSMutableAttributedString()
            .text(actionName.localized().uppercaseFirst + ": " + enteredAmount.currencyValueFormatted + " " + symbol, size: 15, weight: .bold, color: .white)
        
        if burningPercentage > 0 {
            title
                .text("\n")
                .text(String(format: "%.1f%% %@", burningPercentage, "will be burned".localized() + " 🔥"), size: 12, weight: .semibold, color: .white)
                .withParagraphStyle(alignment: .center, paragraphSpacingBefore: 1, paragraphSpacing: 1)
        }
        
        actionButton.setAttributedTitle(title, for: .normal)
        actionButton.titleLabel?.lineBreakMode = .byWordWrapping
        actionButton.titleLabel?.numberOfLines = 0
    }
    
    // MARK: - View modifiers
    func setUp(balances: [ResponseAPIWalletGetBalance]) {
        self.walletCarouselWrapper.balances = balances
        self.walletCarouselWrapper.currentIndex = balances.firstIndex(where: {$0.symbol == self.viewModel.selectedBalance.value?.symbol}) ?? 0
        self.walletCarouselWrapper.reloadData()
    }
    
    func setUp(selectedBalance balance: ResponseAPIWalletGetBalance?) {
        if let balance = balance {
            self.balanceNameLabel.text = balance.name ?? balance.symbol
            self.valueLabel.text = balance.balanceValue.currencyValueFormatted
        } else {
            self.balanceNameLabel.text = "Balance"
            self.valueLabel.text = "0.0000"
        }
    }
    
    func setUp(receiver: ResponseAPIContentGetProfile?) {
        if let receiver = receiver {
            self.receiverAvatarImageView.setAvatar(urlString: receiver.avatarUrl)
            self.receiverNameLabel.text = receiver.username ?? receiver.userId
            self.greenTick.isSelected = true
        } else {
            self.receiverAvatarImageView.image = UIImage(named: "empty-avatar")
            self.receiverNameLabel.text = " ".localized().uppercaseFirst
            self.greenTick.isSelected = false
        }
    }
    
    func setUp(loading: Bool = false) {
        if loading {
            walletCarouselWrapper.showLoader()
            balanceNameLabel.showLoader()
            valueLabel.showLoader()
            receiverAvatarImageView.showLoader()
            receiverNameLabel.showLoader()
            greenTick.showLoader()
            amountTextField.showLoader()
        } else {
            walletCarouselWrapper.hideLoader()
            balanceNameLabel.hideLoader()
            valueLabel.hideLoader()
            receiverAvatarImageView.hideLoader()
            receiverNameLabel.hideLoader()
            greenTick.hideLoader()
            amountTextField.hideLoader()
        }
    }
    
    // MARK: - Validation
    func checkValues() -> Bool {
        if let error = viewModel.error.value?.errorDescription {
            self.hintView?.display(inPosition: actionButton.frame.origin, withType: .error(error), completion: {})
            return false
        }
        
        if enteredAmount == 0 {
            self.hintView?.display(inPosition: actionButton.frame.origin, withType: .enterAmount, completion: {})
            return false
        }
        
        if viewModel.selectedReceiver.value == nil {
            self.hintView?.display(inPosition: actionButton.frame.origin, withType: .chooseFriend, completion: {})
            return false
        }
        
        return viewModel.check(amount: enteredAmount)
    }
    
    // MARK: - Actions
    @objc func pointsListButtonDidTouch() {
        let vc = createChooseBalancesVC()
        
        let nc = SwipeNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    func createChooseBalancesVC() -> BalancesVC {
        BalancesVC { balance in
            self.handleBalanceChosen(balance)
        }
    }
    
    @objc func chooseRecipientViewTapped(_ sender: UITapGestureRecognizer) {
        let friendsListVC = SendPointListVC()
        friendsListVC.completion = { user in
            self.viewModel.selectedReceiver.accept(user)
        }
        
        let nc = SwipeNavigationController(rootViewController: friendsListVC)
        present(nc, animated: true, completion: nil)
    }
    
    override func actionButtonDidTouch() {
        guard checkValues(),
            let transaction = self.prepareTransaction(),
            let friendId = transaction.friend?.id
        else {return}
        
        dismissKeyboard()
        
        let confirmPasscodeVC = ConfirmPasscodeVC()
        present(confirmPasscodeVC, animated: true, completion: nil)
        
        confirmPasscodeVC.completion = {
            // passcode confirmed
            self.showIndetermineHudWithMessage("sending".localized().uppercaseFirst + " \(self.viewModel.selectedBalance.value?.symbol ?? "")")

            BlockchainManager.instance.transferPoints(to: friendId, number: Double(transaction.amount), currency: transaction.symbol.sell, memo: self.memo)
                .flatMapCompletable { RestAPIManager.instance.waitForTransactionWith(id: $0) }
                .subscribe(onCompleted: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.hideHud()
                    strongSelf.transactionDidComplete(transaction: transaction)
                }) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.hideHud()
                    strongSelf.showError(error)
            }
            .disposed(by: self.disposeBag)
        }
    }
    
    func transactionDidComplete(transaction: Transaction) {
        var transaction = transaction
        if transaction.amount > 0 {
            transaction.amount = -transaction.amount
        }
        let completedVC = TransactionCompletedVC(transaction: transaction)
        show(completedVC, sender: nil)
    }
    
    // MARK: - Helpers
    @objc func clearButtonTapped(_ sender: UIButton) {
        amountTextField.changeTextNotify(nil)
        if amountTextField.text?.isEmpty == true {
            view.endEditing(true)
        }
    }
    
    func prepareTransaction() -> Transaction? {
        guard let selectedBalance = viewModel.selectedBalance.value,
            let receiver = viewModel.selectedReceiver.value
        else {return nil}
        var transaction = Transaction(
            amount: CGFloat(enteredAmount),
            symbol: Symbol(sell: selectedBalance.symbol, buy: selectedBalance.symbol),
            operationDate: Date()
        )
        transaction.createFriend(from: receiver)
        
        return transaction
    }
    
    func programmaticallyChangeAmount(to amount: CGFloat) {
        amountTextField.text = String(Double(amount).currencyValueFormatted)
        amountTextField.sendActions(for: .editingChanged)
    }
    
    func handleBalanceChosen(_ balance: ResponseAPIWalletGetBalance) {
        guard let index = viewModel.balances.firstIndex(where: { $0.symbol == balance.symbol }) else { return }
        walletCarouselWrapper.scrollTo(itemAtIndex: index)
    }
}
