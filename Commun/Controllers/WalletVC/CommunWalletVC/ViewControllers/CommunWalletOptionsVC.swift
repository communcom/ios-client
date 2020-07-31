//
//  CommunWalletOptionsVC.swift
//  Commun
//
//  Created by Chung Tran on 4/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CommunWalletOptionsVC: BaseViewController {
    static let hideEmptyPointsKey = "CommunWalletOptionsVC.hideEmptyPointsKey"
    
    // MARK: - Properties
    let optionHeight: CGFloat = 58
    let optionBackgroundColor = UIColor.appWhiteColor
    
    var shouldHideEmptyPoints: Bool { UserDefaults.standard.bool(forKey: CommunWalletOptionsVC.hideEmptyPointsKey) }
    
    var hideEmptyPointCompletion: ((Bool) -> Void)?
    
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
    lazy var headerView: UIView = {
        let view = UIView(height: 58 * Config.heightRatio, backgroundColor: .appWhiteColor)
        let label = UILabel.with(text: "settings".localized().uppercaseFirst, textSize: 15, weight: .semibold)
        view.addSubview(label)
        label.autoCenterInSuperview()
        
        let closeButton = UIButton.close()
        closeButton.addTarget(self, action: #selector(backWithAction), for: .touchUpInside)
        
        view.addSubview(closeButton)
        closeButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        closeButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        return view
    }()
    lazy var stackView = UIStackView(axis: .vertical, spacing: 2, alignment: .fill, distribution: .fill)
    lazy var hideEmptyView: UIView = {
        let view = UIView(height: optionHeight, backgroundColor: optionBackgroundColor)
        let label = UILabel.with(text: "hide empty points".localized().uppercaseFirst, weight: .semibold)
        view.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        view.addSubview(switcher)
        switcher.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        switcher.autoAlignAxis(toSuperviewAxis: .horizontal)
        switcher.autoPinEdge(.leading, to: .trailing, of: label, withOffset: 8)
        switcher.onTintColor = .appMainColor
        switcher.isOn = shouldHideEmptyPoints
        
        return view
    }()
    lazy var switcher = UISwitch()
    
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
        
        let backgroundView = UIView( cornerRadius: 10)
        
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        
        view.addSubview(backgroundView)
        backgroundView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(inset: 16), excludingEdge: .top)
        backgroundView.autoPinEdge(.top, to: .bottom, of: headerView, withOffset: 16) 
        
        backgroundView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        stackView.addArrangedSubviews([
            hideEmptyView,
//            viewInExplorerView
        ])
    }
    
    @objc func backWithAction() {
        if self.shouldHideEmptyPoints != self.switcher.isOn
        {
            hideEmptyPointCompletion?(self.switcher.isOn)
        }
        back()
    }
}

extension CommunWalletOptionsVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CMActionSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
