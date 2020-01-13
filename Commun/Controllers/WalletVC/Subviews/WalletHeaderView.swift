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

class WalletHeaderView: MyView {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var stackViewTopConstraint: NSLayoutConstraint?
    var balances: [ResponseAPIWalletGetBalance]?
    let currentIndex = BehaviorRelay<Int>(value: 0)
    var isCollapsed = true
    
    var titleTopConstraint: NSLayoutConstraint?
    var titleToPoinConstraint: NSLayoutConstraint?
    var pointBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var shadowView = UIView(forAutoLayout: ())
    lazy var contentView = UIView(backgroundColor: .appMainColor)
    
    lazy var backButton = UIButton.back(width: 44, height: 44, tintColor: .white, contentInsets: UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16))
    lazy var communLogo = UIView.transparentCommunLogo(size: 40)
    lazy var carousel: WalletCarousel = {
        let carousel = WalletCarousel(height: 40)
        carousel.scrollingHandler = {index in
            self.currentIndex.accept(index)
        }
        return carousel
    }()
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
        return stackView
    }()
    
    lazy var sendButton = UIButton.circle(size: 30, backgroundColor: UIColor.white.withAlphaComponent(0.2), tintColor: .white, imageName: "upVote", imageEdgeInsets: UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8))
    
    lazy var convertButton = UIButton.circle(size: 30, backgroundColor: UIColor.white.withAlphaComponent(0.2), tintColor: .white, imageName: "convert", imageEdgeInsets: UIEdgeInsets(inset: 6))
    
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
        titleToPoinConstraint = pointLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
        pointLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
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
        
        // stackView
        buttonsStackView.addArrangedSubview(buttonContainerViewWithButton(sendButton, label: "send".localized().uppercaseFirst))
        buttonsStackView.addArrangedSubview(buttonContainerViewWithButton(convertButton, label: "convert".localized().uppercaseFirst))
        
        // pin bottom
        shadowView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 29)
        
        setIsCollapsed(false)
        
        // bind
        bind()
    }
    
    func bind() {
        currentIndex
            .subscribe(onNext: { (index) in
                self.carousel.currentIndex = index
                if index == 0 {
                    self.setUpWithCommunValue()
                } else {
                    self.setUpWithCurrentBalance()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setIsCollapsed(_ value: Bool) {
        if isCollapsed == value {return}
        self.isCollapsed = value
        
        superview?.layoutIfNeeded()
        
        let deactivateConstraints = {
            self.titleTopConstraint?.isActive = false
            self.pointBottomConstraint?.isActive = false
            self.stackViewTopConstraint?.isActive = false
        }
        
        if !isCollapsed {
            deactivateConstraints()
            self.titleTopConstraint = self.titleLabel.autoPinEdge(.top, to: .bottom, of: self.backButton, withOffset: 25)
            
            self.titleToPoinConstraint?.constant = 5
            
            self.titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            self.pointLabel.font = .systemFont(ofSize: 30, weight: .bold)
            
            self.titleLabel.textColor = .white
            self.pointLabel.textColor = .white
            
            self.backButton.tintColor = .white
            self.optionsButton.tintColor = .white
            
            self.contentView.addSubview(self.communLogo)
            self.communLogo.autoAlignAxis(toSuperviewAxis: .vertical)
            self.communLogo.autoAlignAxis(.horizontal, toSameAxisOf: self.backButton)
            
            self.contentView.addSubview(self.carousel)
            self.carousel.autoAlignAxis(toSuperviewAxis: .vertical)
            self.carousel.autoAlignAxis(.horizontal, toSameAxisOf: self.backButton)
            
            self.contentView.addSubview(self.buttonsStackView)
            self.stackViewTopConstraint = self.buttonsStackView.autoPinEdge(.top, to: .bottom, of: self.pointLabel, withOffset: 30 * Config.heightRatio)
            self.buttonsStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16 * Config.widthRatio, bottom: 30 * Config.heightRatio, right: 16 * Config.widthRatio), excludingEdge: .top)
            
            if let balances = self.balances {
                self.setUp(with: balances, animated: false)
            }
        } else {
            self.communLogo.removeFromSuperview()
            self.carousel.removeFromSuperview()
            self.buttonsStackView.removeFromSuperview()
            self.balanceContainerView.removeFromSuperview()
            self.buttonsStackView.removeFromSuperview()
            
            deactivateConstraints()
            
            self.titleTopConstraint = self.titleLabel.autoPinEdge(toSuperviewSafeArea: .top, withInset: 6)
            
            self.titleToPoinConstraint?.constant = 3
            
            self.pointBottomConstraint = self.pointLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
            
            self.titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            self.pointLabel.font = .systemFont(ofSize: 20, weight: .semibold)
            
            self.titleLabel.textColor = .black
            self.pointLabel.textColor = .black
            
            self.contentView.backgroundColor = .white
            
            self.backButton.tintColor = .black
            self.optionsButton.tintColor = .black
        }
        
        UIView.animate(withDuration: 0.3) {
            // https://stackoverflow.com/questions/38646063/constraint-animation-only-partially-animating-causing-what-looks-like-a-jump#comment94319390_38646063
            self.superview?.layoutIfNeeded()
        }
    }
    
    func setUp(with balances: [ResponseAPIWalletGetBalance], animated: Bool = true) {
        self.balances = balances
        carousel.balances = balances
        if currentIndex.value == 0 {
            setUpWithCommunValue(animated: animated)
        } else {
            setUpWithCurrentBalance(animated: animated)
        }
    }
    
    private func setUpWithCommunValue(animated: Bool = true) {
        let point = balances?.first(where: {$0.symbol == "CMN"})?.balanceValue ?? 0
        
        if !isCollapsed {
            // show commun logo
            communLogo.isHidden = false
            carousel.isHidden = true
            
            // remove balanceContainerView if exists
            contentView.backgroundColor = .appMainColor
            if balanceContainerView.isDescendant(of: contentView) {
                balanceContainerView.removeFromSuperview()
                
                stackViewTopConstraint?.isActive = false
                stackViewTopConstraint = buttonsStackView.autoPinEdge(.top, to: .bottom, of: pointLabel, withOffset: 30 * Config.heightRatio)
                if animated {
                    UIView.animate(withDuration: 0.3) {
                        self.superview?.layoutIfNeeded()
                    }
                }
            }
        }
        
        // set up
        titleLabel.text = "enquity Value Commun".localized().uppercaseFirst
        pointLabel.text = "\(point.currencyValueFormatted)"
    }
    
    private func setUpWithCurrentBalance(animated: Bool = true) {
        guard let balances = balances,
            let balance = balances[safe: currentIndex.value]
        else {
            currentIndex.accept(0)
            return
        }
        
        if !isCollapsed {
            // show carousel
            communLogo.isHidden = true
            carousel.isHidden = false
            
            // add balanceContainerView
            contentView.backgroundColor = UIColor(hexString: "#020202")
            if !balanceContainerView.isDescendant(of: contentView) {
                contentView.addSubview(balanceContainerView)
                pointBottomConstraint = balanceContainerView.autoPinEdge(.top, to: .bottom, of: pointLabel)
                balanceContainerView.autoPinEdge(toSuperviewEdge: .leading)
                balanceContainerView.autoPinEdge(toSuperviewEdge: .trailing)
                
                stackViewTopConstraint?.isActive = false
                stackViewTopConstraint = buttonsStackView.autoPinEdge(.top, to: .bottom, of: balanceContainerView, withOffset: 30 * Config.heightRatio)
                if animated {
                    UIView.animate(withDuration: 0.3) {
                        self.superview?.layoutIfNeeded()
                    }
                }
            }
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
        }
        
        // set up
        titleLabel.text = balance.name ?? "" + "balance".localized().uppercaseFirst
        pointLabel.text = "\(balance.balanceValue.currencyValueFormatted)"
        
        contentView.bringSubviewToFront(backButton)
        contentView.bringSubviewToFront(optionsButton)
    }
    
    func startLoading() {
        contentView.hideLoader()
        contentView.showLoader()
    }
    
    func endLoading() {
        contentView.hideLoader()
    }
    
    func makeShadowAndRoundCorner() {
        contentView.roundCorners(UIRectCorner(arrayLiteral: .bottomLeft, .bottomRight), radius: 30 * Config.heightRatio)
        
        var color = UIColor(red: 106, green: 128, blue: 245)!
        var opacity: Float = 0.3
        
        if isCollapsed {
            color = UIColor(red: 108, green: 123, blue: 173)!
            opacity = 0.08
        }
        
        shadowView.addShadow(ofColor: color, radius: 19, offset: CGSize(width: 0, height: 14), opacity: opacity)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.makeShadowAndRoundCorner()
        }
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
    
    func switchToSymbol(_ symbol: String) {
        guard let index = balances?.firstIndex(where: {$0.symbol == symbol}) else {return}
        currentIndex.accept(index)
        carousel.reloadData()
    }
}
