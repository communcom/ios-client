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
import CircularCarousel

protocol WalletHeaderViewDelegate: CommunWalletHeaderViewDelegate {
    func walletHeaderView(_ headerView: WalletHeaderView, currentIndexDidChangeTo index: Int)
}

class WalletHeaderView: CommunWalletHeaderView {
    // MARK: - Constants
    let carouselHeight: CGFloat = 40
    
    // MARK: - Properties
    var selectedIndex = 0
    
    // MARK: - Subviews
    lazy var carousel: WalletCarousel = {
        let carousel = WalletCarousel(width: 300, height: 40)
        carousel.delegate = self
        carousel.dataSource = self
        return carousel
    }()
    
    // MARK: - Balance
    lazy var balanceContainerView = UIView(forAutoLayout: ())
    lazy var communValueLabel = UILabel.with(text: "= 150 Commun", textSize: 12, weight: .semibold, textColor: .white)
    lazy var progressBar = GradientProgressBar(height: 10)
    lazy var availableHoldValueLabel = UILabel.with(text: "available".localized().uppercaseFirst + "/" + "hold".localized().uppercaseFirst, textSize: 12, textColor: .white)
    
    // MARK: - Methods
    override func commonInit() {
        // balance
        layoutBalanceContainerView()
        super.commonInit()
    }
    
    override func reloadData() {
        guard let balances = dataSource?.data(forWalletHeaderView: self),
            let balance = balances[safe: selectedIndex]
            else {return}
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
    }
    
    func setSelectedIndex(_ index: Int, shouldUpdateCarousel: Bool = true) {
        if index == selectedIndex {return}
        
        // if switch from commun to other and vice versa
        var needsReloadViews = false
        if index == 0 || selectedIndex == 0 {
            needsReloadViews = true
        }
        
        selectedIndex = index
        if needsReloadViews {
            carousel.reloadData()
            UIView.animate(withDuration: 0.3) {
                self.reloadViews()
            }
        } else if shouldUpdateCarousel {
            carousel.scroll(toItemAtIndex: index, animated: true)
        }
        
        reloadData()
        (delegate as? WalletHeaderViewDelegate)?.walletHeaderView(self, currentIndexDidChangeTo: index)
    }
    
    // MARK: - Private functions
    override func layoutBalanceExpanded() {
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
        
        contentView.bringSubviewToFront(backButton)
        contentView.bringSubviewToFront(optionsButton)
    }
    
    override func collapse() {
        carousel.removeFromSuperview()
        balanceContainerView.removeFromSuperview()
        super.collapse()
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
}

extension WalletHeaderView: CircularCarouselDataSource, CircularCarouselDelegate {
    func startingItemIndex(inCarousel carousel: CircularCarousel) -> Int {
        return selectedIndex
    }
    
    func numberOfItems(inCarousel carousel: CircularCarousel) -> Int {
        return dataSource?.data(forWalletHeaderView: self)?.count ?? 0
    }
    func carousel(_: CircularCarousel, viewForItemAt indexPath: IndexPath, reuseView: UIView?) -> UIView {
        guard let balance = dataSource?.data(forWalletHeaderView: self)?[safe: indexPath.row] else {return UIView()}
        
        var view = reuseView

        if view == nil || view?.viewWithTag(1) == nil {
            view = UIView(frame: CGRect(x: 0, y: 0, width: carouselHeight, height: carouselHeight))
            let imageView = MyAvatarImageView(size: carouselHeight)
            imageView.borderColor = .white
            imageView.borderWidth = 2
            imageView.tag = 1
            view!.addSubview(imageView)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        }
        
        let imageView = view?.viewWithTag(1) as! MyAvatarImageView
        
        if balance.symbol == "CMN" {
            imageView.image = UIImage(named: "tux")
        } else {
            imageView.setAvatar(urlString: balance.logo, namePlaceHolder: balance.name ?? balance.symbol)
        }
        
        return view!
    }
    // MARK: CircularCarouselDelegate
    func carousel<T>(_ carousel: CircularCarousel, valueForOption option: CircularCarouselOption, withDefaultValue defaultValue: T) -> T {
        if option == .itemWidth {
            return CoreGraphics.CGFloat(carouselHeight) as! T
        }
        
//        if option == .spacing {
//            return CoreGraphics.CGFloat(8) as! T
//        }
        
        if option == .scaleMultiplier {
            return CoreGraphics.CGFloat(0.25) as! T
        }
        
        if option == .minScale {
            return CoreGraphics.CGFloat(0.5) as! T
        }
        
//        if option == .fadeMin {
//            return CoreGraphics.CGFloat(-2) as! T
//        }
//
//        if option == .fadeMax {
//            return CoreGraphics.CGFloat(2) as! T
//        }
        
        if option == .visibleItems {
            return Int(5) as! T
        }
        
        return defaultValue
    }
    
    func carousel(_ carousel: CircularCarousel, willBeginScrollingToIndex index: Int) {
        setSelectedIndex(index, shouldUpdateCarousel: false)
    }
}
