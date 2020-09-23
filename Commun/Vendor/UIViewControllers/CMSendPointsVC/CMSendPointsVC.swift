//
//  CMSendPointsVC.swift
//  Commun
//
//  Created by Chung Tran on 9/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class SendPointsViewModel: BaseViewModel {
    lazy var balancesVM = BalancesViewModel.ofCurrentUser
}

class CMSendPointsVC: CMTransferVC {
    // MARK: - Properties
    override var titleText: String { "send points".localized().uppercaseFirst }
    let viewModel = SendPointsViewModel()
    var balancesVM: BalancesViewModel {viewModel.balancesVM}
    
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
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        // add carousel
        topStackView.insertArrangedSubview(walletCarouselWrapper, at: 0)
        topStackView.setCustomSpacing(20, after: walletCarouselWrapper)
        
        setRightBarButton(imageName: "wallet-right-bar-button", tintColor: .white, action: #selector(chooseRecipientViewTapped))
        
        walletCarouselWrapper.scrollingHandler = { index in
            // TODO: - scrolling handler
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
        
        // test
        balanceNameLabel.text = "Commun"
        valueLabel.text = "6.1243"
    }
    
    // MARK: - Actions
    @objc func chooseRecipientViewTapped(_ sender: UITapGestureRecognizer) {
        let friendsListVC = SendPointListVC()
        friendsListVC.completion = { user in
            // TODO: - Choose recipient
        }
        
        let nc = SwipeNavigationController(rootViewController: friendsListVC)
        present(nc, animated: true, completion: nil)
    }
}
