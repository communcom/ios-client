//
//  TransactionCompletedVC.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 24.12.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

class TransactionCompletedVC: BaseViewController {
    // MARK: - Properties
    var dataModel = SendPointsModel()
    var transactionCompletedView: TransactionCompletedView!
    
    var completionRepeat: (() -> Void)?
    var completionDismiss: (() -> Void)?

    // MARK: - Class Initialization
    init(transaction: Transaction) {
        self.dataModel.transaction = transaction
        self.transactionCompletedView = TransactionCompletedView(withMode: transaction.actionType)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        dataModel.transaction.history == nil ? setupNavBar() : addGesture()

        dataModel.loadBalances { [weak self] success in
            guard let strongSelf = self else { return }
            
            if success {
                strongSelf.setupView()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupNavBar()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setTabBarHidden(false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        view.backgroundColor = dataModel.transaction.history == nil ? #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1) : #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
    }

    // MARK: - Custom Functions
    private func setupNavBar() {
        title = "send points".localized().uppercaseFirst
        setLeftNavBarButtonForGoingBack(tintColor: .white)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // items color
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1) // bar color
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage?.clear()
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopBarButtonTapped))

        setTabBarHidden(true)
    }

    private func setupView() {
        dataModel.transaction.buyBalance = dataModel.getBalance(bySymbol: dataModel.transaction.symbol.buy)
        dataModel.transaction.sellBalance = dataModel.getBalance(bySymbol: dataModel.transaction.symbol.sell)

        transactionCompletedView.updateSellerInfo(fromTransaction: dataModel.transaction)
        transactionCompletedView.updateTransactionInfo(dataModel.transaction)
        transactionCompletedView.updateBuyerInfo(fromTransaction: dataModel.transaction)
        
        view.addSubview(transactionCompletedView)
        transactionCompletedView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(horizontal: .adaptive(width: 40.0), vertical: .adaptive(height: 20.0)), excludingEdge: .top)
        
        // Actions
        self.transactionCompletedView.actions { [weak self] actionType in
            guard let strongSelf = self else { return }
            
            switch actionType {
            case .repeat:
                strongSelf.showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
                strongSelf.dismiss()
                strongSelf.completionRepeat!()

            case .wallet:
                strongSelf.backToWallet()
                
            default:
                // Return to `Feed` page
                if let tabBarVC = strongSelf.tabBarController as? TabBarVC {
                    tabBarVC.setTabBarHiden(false)
                    tabBarVC.switchTab(index: 0)
                    strongSelf.navigationController?.popToRootViewController(animated: false)
                    tabBarVC.appLiked()
                }
            }
        }
    }
    
    private func backToWallet() {
        if let walletVC = navigationController?.viewControllers.filter({ $0 is CommunWalletVC }).first as? CommunWalletVC {
            navigationController?.popToViewController(walletVC, animated: true)
            walletVC.viewModel.reload()
            walletVC.appLiked()
        }
    }
    
    private func addGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    private func dismiss() {
        completionDismiss!()
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Actions
    @objc func viewTapped( _ sender: UITapGestureRecognizer) {
        dismiss()
    }

    @objc func actionBarButtonTapped(_ sender: UIBarButtonItem) {
        // TODO: - ADD ACTION
        showAlert(title: "TODO", message: "Add action")
    }

    @objc func stopBarButtonTapped(_ sender: UIBarButtonItem) {
        backToWallet()
    }
}
