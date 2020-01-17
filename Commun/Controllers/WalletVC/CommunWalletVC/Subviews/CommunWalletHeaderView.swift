//
//  CommunWalletHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 1/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol CommunWalletHeaderViewDatasource: class {
    func data(forWalletHeaderView headerView: CommunWalletHeaderView) -> [ResponseAPIWalletGetBalance]?
}

protocol CommunWalletHeaderViewDelegate: class {
    func walletHeaderView(_ headerView: CommunWalletHeaderView, willUpdateHeightCollapsed isCollapsed: Bool)
}

class CommunWalletHeaderView: MyView {
    // MARK: - Properties
    var isCollapsed = false
    weak var delegate: CommunWalletHeaderViewDelegate?
    weak var dataSource: CommunWalletHeaderViewDatasource?
    
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
    
    lazy var optionsButton = UIButton.option(tintColor: .white)
    lazy var titleLabel = UILabel.with(text: "Equity Value Commun", textSize: 15, weight: .semibold, textColor: .white)
    lazy var pointLabel = UILabel.with(text: "167 500.23", textSize: 30, weight: .bold, textColor: .white, textAlignment: .center)
    
    // MARK: - Buttons
    lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(axis: .horizontal)
        stackView.addBackground(color: UIColor.white.withAlphaComponent(0.1), cornerRadius: 16)
        stackView.cornerRadius = 16
        
        // stackView
        sendButton.accessibilityHint = Config.defaultSymbol
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
        
        // pin bottom
        shadowView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 29)
        
        reloadViews()
    }
    
    func reloadData() {
        guard let balances = dataSource?.data(forWalletHeaderView: self),
            let point = balances.first(where: {$0.symbol == Config.defaultSymbol})?.balanceValue
        else {return}
        // set up with commun value
        titleLabel.text = "enquity Value Commun".localized().uppercaseFirst
        pointLabel.text = "\(point.currencyValueFormatted)"
    }
    
    func setIsCollapsed(_ value: Bool) {
        if isCollapsed == value {return}
        isCollapsed = value
        UIView.animate(withDuration: 0.3) {
            self.reloadViews()
        }
    }
    
    // MARK: - Private functions
    func reloadViews() {
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
        layoutBalanceExpanded()
        
        // modify fonts, colors
        self.contentView.backgroundColor = .appMainColor
        
        self.titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        self.pointLabel.font = .systemFont(ofSize: 30, weight: .bold)
        
        self.titleLabel.textColor = .white
        self.pointLabel.textColor = .white
        
        self.backButton.tintColor = .white
        self.optionsButton.tintColor = .white
    }
    
    func layoutBalanceExpanded() {
        if !communLogo.isDescendant(of: contentView) {
            contentView.addSubview(communLogo)
            communLogo.autoAlignAxis(toSuperviewAxis: .vertical)
            communLogo.autoAlignAxis(.horizontal, toSameAxisOf: backButton)
        }
        stackViewTopConstraint = buttonsStackView.autoPinEdge(.top, to: .bottom, of: pointLabel, withOffset: 30 * Config.heightRatio)
    }
    
    func collapse() {
        // remove unused views
        communLogo.removeFromSuperview()
        buttonsStackView.removeFromSuperview()
        
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
    
    // MARK: - Helpers
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
}
