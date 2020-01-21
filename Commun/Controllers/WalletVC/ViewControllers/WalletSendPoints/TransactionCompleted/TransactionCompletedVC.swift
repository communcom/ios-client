//
//  TransactionCompletedVC.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 24.12.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

class TransactionCompletedVC: UIViewController {
    // MARK: - Properties
    var dataModel = SendPointsModel(withSelectedBalanceSymbol: Config.defaultSymbol)
    var transaction: Transaction!
    var transactionCompletedView: TransactionCompletedView!
    
    var completionDismiss: (() -> Void)?
    var completionRepeat: ((Transaction) -> Void)?

    
    // MARK: - Class Initialization
    init(transaction: Transaction) {
        self.dataModel.transaction = transaction
        self.transactionCompletedView = TransactionCompletedView(withHistoryMode: transaction.history != nil)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        title = "send points".localized()
        setLeftNavBarButtonForGoingBack(tintColor: .white)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionBarButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopBarButtonTapped))
    }
    
    private func setupView() {
        transactionCompletedView.update(balance: dataModel.currentBalance)
        transactionCompletedView.update(transaction: dataModel.transaction)
        transactionCompletedView.update(recipient: dataModel.transaction.recipient)
        
        view.addSubview(transactionCompletedView)
        transactionCompletedView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(horizontal: CGFloat.adaptive(width: 40.0), vertical: CGFloat.adaptive(height: 20.0)), excludingEdge: .top)
        transactionCompletedView.heightAnchor.constraint(equalToConstant: transactionCompletedView.bounds.height).isActive = true
        
        // Actions
        self.transactionCompletedView.actions { [weak self] actionType in
            guard let strongSelf = self else { return }
            
            switch actionType {
            case .repeat:
                strongSelf.showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
                strongSelf.dismiss()
                strongSelf.completionRepeat!(strongSelf.dataModel.transaction)

            case .wallet:
                strongSelf.backToWallet()
                
            default:
                // Return to `Feed` page
                if let tabBarVC = strongSelf.tabBarController as? TabBarVC {
                    tabBarVC.setTabBarHiden(false)
                    tabBarVC.switchTab(index: 0)
                    strongSelf.navigationController?.popToRootViewController(animated: false)
                }
            }
        }
    }
    
    private func backToWallet() {
        if let walletVC = navigationController?.viewControllers.filter({ $0 is CommunWalletVC }).first {
            navigationController?.popToViewController(walletVC, animated: true)
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
