//
//  TransactionInfoVC.swift
//  Commun
//
//  Created by Chung Tran on 4/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class TransactionInfoVC: BaseViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {.lightContent}
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.hidden}
    
    // MARK: - Propertes
    var backgroundColor: UIColor {#colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)}
    let viewModel = SendPointsModel()
    var completionRepeat: (() -> Void)?
    var transaction: Transaction {viewModel.transaction}
    private var shouldShowRepeatButton: Bool {
        transaction.actionType?.starts(with: "referral") == false
    }
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    lazy var transactionInfoView = CMTransactionInfoView(transaction: transaction)
    
    lazy var buttonStackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    
    private lazy var repeatButton = UIButton(height: 56 * Config.heightRatio, label: "repeat".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .bold), backgroundColor: .appLightGrayColor, textColor: .appMainColor, cornerRadius: 28 * Config.heightRatio)
    
    // MARK: - Initializers
    init(transaction: Transaction) {
        viewModel.transaction = transaction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        view.backgroundColor = backgroundColor
        
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(horizontal: .adaptive(width: 40.0), vertical: .adaptive(height: 20.0)))
        
        scrollView.contentView.addSubview(transactionInfoView)
        transactionInfoView.autoPinEdge(toSuperviewEdge: .leading)
        transactionInfoView.autoPinEdge(toSuperviewEdge: .trailing)
        
        transactionInfoView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.contentView.topAnchor)
            .isActive = true
        
        scrollView.contentView.addSubview(buttonStackView)
        buttonStackView.autoPinEdge(toSuperviewEdge: .leading)
        buttonStackView.autoPinEdge(toSuperviewEdge: .trailing)
        buttonStackView.autoPinEdge(toSuperviewEdge: .bottom)
        
        buttonStackView.autoPinEdge(.top, to: .bottom, of: transactionInfoView, withOffset: 34 * Config.heightRatio)
        
        buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: .adaptive(height: -20.0))
            .isActive = true
        
        setUpButtonStackView()
        viewDidSetUpButtonStackView()
        
        loadBalances()
    }
    
    func setUpButtonStackView() {
        if shouldShowRepeatButton {
            buttonStackView.addArrangedSubview(repeatButton)
        }
    }
    
    func viewDidSetUpButtonStackView() {
        if shouldShowRepeatButton {
            repeatButton.addTarget(self, action: #selector(repeatsButtonDidTouch), for: .touchUpInside)
        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissWithCompletion)))
    }
    
    private func loadBalances() {
        viewModel.loadBalances { [weak self] success in
            guard let strongSelf = self else { return }
            
            if success {
                strongSelf.viewModel.transaction.buyBalance = strongSelf.viewModel.getBalance(bySymbol: strongSelf.viewModel.transaction.symbol.buy)
                strongSelf.viewModel.transaction.sellBalance = strongSelf.viewModel.getBalance(bySymbol: strongSelf.viewModel.transaction.symbol.sell)
                strongSelf.transactionInfoView.setUp(buyBalance: strongSelf.transaction.buyBalance, sellBalance: strongSelf.transaction.sellBalance)
            } else {
                strongSelf.transactionInfoView.showErrorView {
                    strongSelf.transactionInfoView.hideErrorView()
                    strongSelf.loadBalances()
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc func repeatsButtonDidTouch() {
        showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
        dismissWithCompletion()
        completionRepeat?()
    }
    
    @objc func dismissWithCompletion() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func stopBarButtonTapped(_ sender: UIBarButtonItem) {
        backToWallet()
    }
    
    func backToWallet() {
        if let walletVC = navigationController?.viewControllers.filter({ $0 is CommunWalletVC }).first as? CommunWalletVC {
            navigationController?.popToViewController(walletVC, animated: true)
            walletVC.viewModel.reload()
            walletVC.appLiked()
        }
    }
}
