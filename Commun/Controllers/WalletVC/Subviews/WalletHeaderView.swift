//
//  WalletHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 12/30/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol WalletHeaderViewDatasource: class {
    func data(forWalletHeaderView headerView: WalletHeaderView) -> [ResponseAPIWalletGetBalance]?
}

protocol WalletHeaderViewDelegate: class {
    func walletHeaderView(_ headerView: WalletHeaderView, willUpdateHeightCollapsed isCollapsed: Bool)
    func walletHeaderView(_ headerView: WalletHeaderView, currentIndexDidChangeTo index: Int)
}

class WalletHeaderView: MyView {
    // MARK: - Constants
    weak var dataSource: WalletHeaderViewDatasource?
    weak var delegate: WalletHeaderViewDelegate?
    
    // MARK: - Properties
    var isCollapsed = false
    var selectedIndex = 0
    
    // MARK: - ConfigurableConstraints
    var titleTopConstraint: NSLayoutConstraint?
    var titleToPointConstraint: NSLayoutConstraint?
    var pointBottomConstraint: NSLayoutConstraint?
    var stackViewTopConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var shadowView = UIView(forAutoLayout: ())
    lazy var contentView = UIView(backgroundColor: .appMainColor)
    
    lazy var backButton = UIButton.back(width: 44, height: 44, tintColor: .white, contentInsets: UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16))
    
    lazy var communLogo = UIView.transparentCommunLogo(size: 40)
    lazy var carousel = UIView.transparentCommunLogo(size: 40, backgroundColor: .black)
    
    lazy var optionsButton = UIButton.option(tintColor: .white)
    lazy var titleLabel = UILabel.with(text: "Equity Value Commun", textSize: 15, weight: .semibold, textColor: .white)
    lazy var pointLabel = UILabel.with(text: "167 500.23", textSize: 30, weight: .bold, textColor: .white, textAlignment: .center)
    
    // MARK: - Balance
    lazy var balanceContainerView = UIView(forAutoLayout: ())
    lazy var communValueLabel = UILabel.with(text: "= 150 Commun", textSize: 12, weight: .semibold, textColor: .white)
    lazy var progressBar = GradientProgressBar(height: 10)
    lazy var availableHoldValueLabel = UILabel.with(text: "available".localized().uppercaseFirst + "/" + "hold".localized().uppercaseFirst, textSize: 12, textColor: .white)
    
    // MARK: - Buttons
    lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(axis: .horizontal)
        stackView.addBackground(color: UIColor.white.withAlphaComponent(0.1), cornerRadius: 16)
        stackView.cornerRadius = 16
        // stackView
        stackView.addArrangedSubview(buttonContainerViewWithButton(sendButton, label: "send".localized().uppercaseFirst))
        stackView.addArrangedSubview(buttonContainerViewWithButton(convertButton, label: "convert".localized().uppercaseFirst))
        return stackView
    }()
    
    lazy var sendButton = UIButton.circle(size: 30, backgroundColor: UIColor.white.withAlphaComponent(0.2), tintColor: .white, imageName: "upVote", imageEdgeInsets: UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8))
    
    lazy var convertButton = UIButton.circle(size: 30, backgroundColor: UIColor.white.withAlphaComponent(0.2), tintColor: .white, imageName: "convert", imageEdgeInsets: UIEdgeInsets(inset: 6))
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        addSubview(shadowView)
        shadowView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        shadowView.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        
        contentView.addSubview(backButton)
        backButton.autoPinEdge(toSuperviewSafeArea: .top, withInset: 8)
        backButton.autoPinEdge(toSuperviewSafeArea: .leading)
        
        contentView.addSubview(optionsButton)
        optionsButton.autoPinEdge(toSuperviewSafeArea: .trailing)
        optionsButton.autoAlignAxis(.horizontal, toSameAxisOf: backButton)
        
        contentView.addSubview(titleLabel)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        contentView.addSubview(pointLabel)
        titleToPointConstraint = pointLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
        pointLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // balance
        layoutBalanceContainerView()
        
        // pin bottom
        shadowView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 29)
        
        reloadViews()
    }
    
    func reloadData() {
        guard let balances = dataSource?.data(forWalletHeaderView: self)
        else {return}
        if selectedIndex == 0 {
            guard let point = balances.first(where: {$0.symbol == "CMN"})?.balanceValue else {return}
            // set up with commun value
            titleLabel.text = "enquity Value Commun".localized().uppercaseFirst
            pointLabel.text = "\(point.currencyValueFormatted)"
        } else {
            guard let balance = balances[safe: selectedIndex] else {return}
            // set up with other value
            communValueLabel.text = "= \(balance.communValue.currencyValueFormatted)" + " " + "Commun"
            availableHoldValueLabel.attributedText = NSMutableAttributedString()
                .text("\(balance.balanceValue.currencyValueFormatted)", size: 12, color: .white)
                .text("/\(balance.frozenValue.currencyValueFormatted)", size: 12, color: UIColor.white.withAlphaComponent(0.5))
            
            // progress bar
            var progress: Double = 0
            let total = balance.balanceValue + balance.frozenValue
            if total == 0 {
                progress = 0
            } else {
                progress = balance.balanceValue / total
            }
            progressBar.progress = CGFloat(progress)
            
            titleLabel.text = balance.name ?? "" + "balance".localized().uppercaseFirst
            pointLabel.text = "\(balance.balanceValue.currencyValueFormatted)"
//
//            contentView.bringSubviewToFront(backButton)
//            contentView.bringSubviewToFront(optionsButton)
        }
    }
    
    func setIsCollapsed(_ value: Bool) {
        if isCollapsed == value {return}
        isCollapsed = value
        UIView.animate(withDuration: 0.3) {
            self.reloadViews()
        }
    }
    
    func setSelectedIndex(_ index: Int) {
        if index == selectedIndex {return}
        
        // if switch from commun to other and vice versa
        var needsReloadViews = false
        if index == 0 || selectedIndex == 0 {
            needsReloadViews = true
        }
        
        selectedIndex = index
        if needsReloadViews {
            reloadViews()
        }
        reloadData()
    }
    
    // MARK: - Layout
    func startLoading() {
        contentView.hideLoader()
        contentView.showLoader()
    }
    
    func endLoading() {
        contentView.hideLoader()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        delegate?.walletHeaderView(self, willUpdateHeightCollapsed: isCollapsed)
        DispatchQueue.main.async {
            self.makeShadowAndRoundCorner()
        }
    }
    
    // MARK: - Private functions
    private func reloadViews() {
        if isCollapsed {
            collapse()
        } else {
            expand()
        }
    }
    
    private func expand() {
        // deactivate non-needed constraints
        titleTopConstraint?.isActive = false
        pointBottomConstraint?.isActive = false
        stackViewTopConstraint?.isActive = false
        
        // modify topConstraint
        titleTopConstraint = titleLabel.autoPinEdge(.top, to: .bottom, of: backButton, withOffset: 25)
        
        // modify space between title and point label
        titleToPointConstraint?.constant = 5
        
        // add stackview
        if !buttonsStackView.isDescendant(of: contentView) {
            contentView.addSubview(buttonsStackView)
            buttonsStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16 * Config.widthRatio, bottom: 30 * Config.heightRatio, right: 16 * Config.widthRatio), excludingEdge: .top)
        }
        
        // add needed views
        if selectedIndex == 0 {
            // set up with commun value
            contentView.backgroundColor = .appMainColor
            
            // remove unused views
            carousel.removeFromSuperview()
            balanceContainerView.removeFromSuperview()
            
            // add communLogo
            if !communLogo.isDescendant(of: contentView) {
                contentView.addSubview(communLogo)
                communLogo.autoAlignAxis(toSuperviewAxis: .vertical)
                communLogo.autoAlignAxis(.horizontal, toSameAxisOf: backButton)
            }
            
            // modify stackview top constraint
            stackViewTopConstraint = buttonsStackView.autoPinEdge(.top, to: .bottom, of: pointLabel, withOffset: 30 * Config.heightRatio)
        } else {
            // set up with other value
            contentView.backgroundColor = .black
            
            // remove unused views
            communLogo.removeFromSuperview()
            
            // add carousel
            if !carousel.isDescendant(of: contentView) {
                contentView.addSubview(carousel)
                carousel.autoAlignAxis(toSuperviewAxis: .vertical)
                carousel.autoAlignAxis(.horizontal, toSameAxisOf: backButton)
            }
            
            // add balance container
            if !balanceContainerView.isDescendant(of: contentView) {
                contentView.addSubview(balanceContainerView)
                pointBottomConstraint = balanceContainerView.autoPinEdge(.top, to: .bottom, of: pointLabel)
                balanceContainerView.autoPinEdge(toSuperviewEdge: .leading)
                balanceContainerView.autoPinEdge(toSuperviewEdge: .trailing)
                
                stackViewTopConstraint = buttonsStackView.autoPinEdge(.top, to: .bottom, of: balanceContainerView, withOffset: 30 * Config.heightRatio)
            }
        }
        
        // modify fonts, colors
        self.titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        self.pointLabel.font = .systemFont(ofSize: 30, weight: .bold)
        
        self.titleLabel.textColor = .white
        self.pointLabel.textColor = .white
        
        self.backButton.tintColor = .white
        self.optionsButton.tintColor = .white
    }
    
    private func collapse() {
        // remove unused views
        communLogo.removeFromSuperview()
        carousel.removeFromSuperview()
        buttonsStackView.removeFromSuperview()
        balanceContainerView.removeFromSuperview()
        
        // deactivate non-needed constraints
        titleTopConstraint?.isActive = false
        pointBottomConstraint?.isActive = false
        
        // modify constraints
        titleTopConstraint = titleLabel.autoPinEdge(toSuperviewSafeArea: .top, withInset: 6)
        titleToPointConstraint?.constant = 3
        pointBottomConstraint = pointLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        
        // modify fonts, colors
        self.contentView.backgroundColor = .white
        
        self.titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        self.pointLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        
        self.titleLabel.textColor = .black
        self.pointLabel.textColor = .black
        
        self.backButton.tintColor = .black
        self.optionsButton.tintColor = .black
    }
    
    // MARK: - Helpers
    private func layoutBalanceContainerView() {
        // balance
        balanceContainerView.addSubview(communValueLabel)
        communValueLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 5)
        communValueLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        balanceContainerView.addSubview(progressBar)
        progressBar.autoPinEdge(.top, to: .bottom, of: communValueLabel, withOffset: 32 * Config.heightRatio)
        progressBar.autoPinEdge(toSuperviewEdge: .leading, withInset: 22 * Config.widthRatio)
        progressBar.autoPinEdge(toSuperviewEdge: .trailing, withInset: 22 * Config.widthRatio)
        
        let label = UILabel.with(textSize: 12, textColor: .white)
        label.attributedText = NSMutableAttributedString()
            .text("available".localized().uppercaseFirst, size: 12, color: .white)
            .text("/" + "hold".localized().uppercaseFirst, size: 12, color: UIColor.white.withAlphaComponent(0.5))
        
        balanceContainerView.addSubview(label)
        label.autoPinEdge(.leading, to: .leading, of: progressBar)
        label.autoPinEdge(.top, to: .bottom, of: progressBar, withOffset: 12)
        label.autoPinEdge(toSuperviewEdge: .bottom)
        
        balanceContainerView.addSubview(availableHoldValueLabel)
        availableHoldValueLabel.autoPinEdge(.top, to: .bottom, of: progressBar, withOffset: 12)
        availableHoldValueLabel.autoPinEdge(.trailing, to: .trailing, of: progressBar)
    }
    
    private func buttonContainerViewWithButton(_ button: UIButton, label: String) -> UIView {
        let container = UIView(forAutoLayout: ())
        container.addSubview(button)
        button.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        button.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let label = UILabel.with(text: label, textSize: 12, textColor: .white)
        container.addSubview(label)
        label.autoPinEdge(.top, to: .bottom, of: button, withOffset: 7)
        label.autoAlignAxis(toSuperviewAxis: .vertical)
        label.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        
        return container
    }
    
    private func makeShadowAndRoundCorner() {
        contentView.roundCorners(UIRectCorner(arrayLiteral: .bottomLeft, .bottomRight), radius: 30 * Config.heightRatio)
        
        var color = UIColor(red: 106, green: 128, blue: 245)!
        var opacity: Float = 0.3
        
        if isCollapsed {
            color = UIColor(red: 108, green: 123, blue: 173)!
            opacity = 0.08
        }
        
        shadowView.addShadow(ofColor: color, radius: 19, offset: CGSize(width: 0, height: 14), opacity: opacity)
    }
}
