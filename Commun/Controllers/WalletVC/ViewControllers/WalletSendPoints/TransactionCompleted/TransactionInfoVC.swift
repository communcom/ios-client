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
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {
        if transaction.history == nil {
            return .normal(translucent: true, backgroundColor: .appMainColor, textColor: .white)
        } else {
            return .hidden
        }
    }
    
    override var shouldHideTabBar: Bool {true}
    
    // MARK: - Propertes
    let viewModel = SendPointsModel()
    var completionRepeat: (() -> Void)?
    var transaction: Transaction {viewModel.transaction}
    var isHistoryMode: Bool {
        !["buy", "sell", "send"].contains(transaction.actionType.rawValue)
    }
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    lazy var transactionInfoView = CMTransactionInfoView(transaction: transaction)
    
    lazy var buttonStackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    
    lazy var homeButton = UIButton(height: 56 * Config.heightRatio, label: "home".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .bold), backgroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), cornerRadius: 28 * Config.heightRatio)
    
    lazy var backToWalletButton = UIButton(height: 56 * Config.heightRatio, label: "back to wallet".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .bold), backgroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), textColor: #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1), cornerRadius: 28 * Config.heightRatio)
    lazy var repeatButton = UIButton(height: 56 * Config.heightRatio, label: "repeat".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .bold), backgroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), textColor: #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1), cornerRadius: 28 * Config.heightRatio)
    
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
        if transaction.history == nil {
            title = "send points".localized().uppercaseFirst
            view.backgroundColor =  #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1)
        } else {
            view.backgroundColor = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        }
        
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
        
        buttonStackView.autoPinEdge(.top, to: .bottom, of: transactionInfoView, withOffset: 34 * Config.heightRatio)
        
        buttonStackView.addArrangedSubviews(isHistoryMode ? [repeatButton] : [homeButton, backToWalletButton])
        
        buttonStackView.autoPinEdge(.bottom, to: .bottom, of: view, withOffset: .adaptive(height: -20.0))
        
        homeButton.addTarget(self, action: #selector(homeButtonDidTouch), for: .touchUpInside)
        repeatButton.addTarget(self, action: #selector(repeatsButtonDidTouch), for: .touchUpInside)
        backToWalletButton.addTarget(self, action: #selector(backToWalletButtonDidTouch), for: .touchUpInside)
        
        // dismiss
        if transaction.history != nil {
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissWithCompletion)))
        }
        
        loadBalances()
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
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        
        if transaction.history == nil {
            setLeftNavBarButtonForGoingBack(tintColor: .white)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopBarButtonTapped))
        }
    }
    
    // MARK: - Actions
    @objc func homeButtonDidTouch() {
        // Return to `Feed` page
        if let tabBarVC = tabBarController as? TabBarVC {
            tabBarVC.setTabBarHiden(false)
            tabBarVC.switchTab(index: 0)
            navigationController?.popToRootViewController(animated: false)
            tabBarVC.appLiked()
        }
    }
    
    @objc func repeatsButtonDidTouch() {
        showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
        dismissWithCompletion()
        completionRepeat?()
    }
    
    @objc func dismissWithCompletion() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func backToWalletButtonDidTouch() {
        backToWallet()
    }
    
    @objc func stopBarButtonTapped(_ sender: UIBarButtonItem) {
        backToWallet()
    }
    
    private func backToWallet() {
        if let walletVC = navigationController?.viewControllers.filter({ $0 is CommunWalletVC }).first as? CommunWalletVC {
            navigationController?.popToViewController(walletVC, animated: true)
            walletVC.viewModel.reload()
            walletVC.appLiked()
        }
    }
}
