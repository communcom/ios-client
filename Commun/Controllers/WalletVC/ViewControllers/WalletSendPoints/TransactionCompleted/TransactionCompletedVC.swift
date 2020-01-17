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
    
    
    // MARK: - Class Initialization
    init(transaction: Transaction) {
        self.dataModel.transaction = transaction
        self.transactionCompletedView = TransactionCompletedView(withType: transaction.type)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        dataModel.transaction.type == .send ? setupNavBar() : navigationController?.setToolbarHidden(true, animated: false)

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
        setupTabBar(hide: true)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setupTabBar(hide: false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        view.backgroundColor = dataModel.transaction.type == .send ? #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1) : #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        
        if dataModel.transaction.type == .history {
            view.superview?.frame = CGRect(x: 0.0, y: CGFloat.adaptive(height: 201.0), width: view.frame.width, height: CGFloat.adaptive(height: 567.0))
        }
    }

    
    // MARK: - Custom Functions
    private func setupNavBar() {
        title = "send points".localized()
        setLeftNavBarButtonForGoingBack(tintColor: .white)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionBarButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopBarButtonTapped))
    }
    
    private func setupTabBar(hide isHidden: Bool) {
        tabBarController?.tabBar.isHidden = isHidden
        let tabBarVC = (tabBarController as? TabBarVC)
        tabBarVC?.setTabBarHiden(isHidden)
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
                // TODO: - ADD ACTION
                strongSelf.showAlert(title: "TODO", message: "Add action")

            case .wallet:
                strongSelf.backToWallet()
                
            default:
                // Display `Feed` page
                strongSelf.tabBarController?.selectedIndex = 0
                strongSelf.navigationController?.popToRootViewController(animated: false)
            }
        }
    }
    
    private func backToWallet() {
        if let walletVC = navigationController?.viewControllers.filter({ $0 is CommunWalletVC }).first {
            navigationController?.popToViewController(walletVC, animated: true)
        }
    }
    
    
    // MARK: - Actions
    @objc func actionBarButtonTapped(_ sender: UIBarButtonItem) {
        // TODO: - ADD ACTION
        showAlert(title: "TODO", message: "Add action")
    }

    @objc func stopBarButtonTapped(_ sender: UIBarButtonItem) {
        backToWallet()
    }
}
