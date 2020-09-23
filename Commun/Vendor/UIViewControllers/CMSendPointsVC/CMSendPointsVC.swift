//
//  CMSendPointsVC.swift
//  Commun
//
//  Created by Chung Tran on 9/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMSendPointsVC: CMTransferVC {
    // MARK: - Properties
    override var titleText: String { "send points".localized().uppercaseFirst }
    let viewModel = CMSendPointsViewModel()
    
    // MARK: - Subviews
    lazy var walletCarouselWrapper = WalletCarouselWrapper(height: 50)
    lazy var receiverAvatarImageView = MyAvatarImageView(size: 40)
    lazy var receiverNameLabel = UILabel.with(textSize: 15, weight: .semibold)
    lazy var greenTick: UIButton = {
        let button = UIButton.circle(size: 24, backgroundColor: .clear, tintColor: .appWhiteColor, imageName: "icon-select-user-grey-cyrcle-default", imageEdgeInsets: .zero)
        button.setImage(UIImage(named: "icon-select-user-green-cyrcle-selected"), for: .selected)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    lazy var amountTextField = createTextField()
    
    // MARK: - Initializers
    init(selectedBalanceSymbol: String? = nil, receiver: ResponseAPIContentGetProfile? = nil) {
        super.init(nibName: nil, bundle: nil)
        defer {
            viewModel.selectedReceiver.accept(receiver)
            viewModel.balancesVM.state.filter {$0 == .listEnded}.take(1).asSingle()
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
        
        setRightBarButton(imageName: "wallet-right-bar-button", tintColor: .white, action: #selector(chooseRecipientViewTapped))
        
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
        
        // add amountContainer
        let amountContainer: UIView = {
            let view = borderedView()
            
            let stackView = UIStackView(axis: .vertical, spacing: 8, alignment: .fill, distribution: .fill)
            view.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
            
            let amountLabel = UILabel.with(text: "amount".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: .appGrayColor)
            stackView.addArrangedSubviews([amountLabel, amountTextField])
            
            return view
        }()
        
        stackView.addArrangedSubviews([receiverContainer, amountContainer])
    }
    
    override func bind() {
        super.bind()
        bindBalances()
        bindReceiver()
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
            self.balanceNameLabel.text = nil
            self.valueLabel.text = nil
        }
    }
    
    func setUp(receiver: ResponseAPIContentGetProfile?) {
        if let receiver = receiver {
            self.receiverAvatarImageView.setAvatar(urlString: receiver.avatarUrl)
            self.receiverNameLabel.text = receiver.username ?? receiver.userId
        } else {
            self.receiverAvatarImageView.image = UIImage(named: "empty-avatar")
            self.receiverNameLabel.text = nil
        }
    }
    
    // MARK: - Actions
    @objc func chooseRecipientViewTapped(_ sender: UITapGestureRecognizer) {
        let friendsListVC = SendPointListVC()
        friendsListVC.completion = { user in
            self.viewModel.selectedReceiver.accept(user)
        }
        
        let nc = SwipeNavigationController(rootViewController: friendsListVC)
        present(nc, animated: true, completion: nil)
    }
}
