//
//  CommunWalletOptionsVC.swift
//  Commun
//
//  Created by Chung Tran on 4/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CommunWalletOptionsVC: BaseViewController {
    // MARK: - Properties
    let optionHeight: CGFloat = 58
    let optionBackgroundColor = UIColor.appWhiteColor
    
    // MARK: - Initializers
    init() {
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, spacing: 2, alignment: .fill, distribution: .fill)
    lazy var hideEmptyView: UIView = {
        let view = UIView(height: optionHeight, backgroundColor: optionBackgroundColor)
        let label = UILabel.with(text: "hide empty points".localized().uppercaseFirst, weight: .semibold)
        view.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        let switcher = UISwitch()
        view.addSubview(switcher)
        switcher.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        switcher.autoAlignAxis(toSuperviewAxis: .horizontal)
        switcher.autoPinEdge(.leading, to: .trailing, of: label, withOffset: 8)
        
        return view
    }()
    lazy var viewInExplorerView: UIView = {
        let view = UIView(height: optionHeight, backgroundColor: optionBackgroundColor)
        let label = UILabel.with(text: "view in Explorer".localized().uppercaseFirst, weight: .semibold)
        view.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        let nextButton = UIButton.circleGray(imageName: "cell-arrow", imageEdgeInsets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        nextButton.isUserInteractionEnabled = false
        view.addSubview(nextButton)
        nextButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        nextButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        nextButton.autoPinEdge(.leading, to: .trailing, of: label, withOffset: 8)
        return view
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "settings".localized().uppercaseFirst
        view.backgroundColor = .appLightGrayColor
        
        let closeButton = UIButton.close()
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        setRightNavBarButton(with: closeButton)
        
        let backgroundView = UIView( cornerRadius: 10)
        
        view.addSubview(backgroundView)
        backgroundView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(inset: 16))
        
        backgroundView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        stackView.addArrangedSubviews([
            hideEmptyView,
            viewInExplorerView
        ])
    }
}

extension CommunWalletOptionsVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CMActionSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
