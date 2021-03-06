//
//  WalletCarousel.swift
//  Commun
//
//  Created by Chung Tran on 12/27/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CircularCarousel

class WalletCarouselWrapper: MyView {
    // MARK: - Constants
    var carouselHeight: CGFloat

    // MARK: - Properties
    var currentIndex: Int = 0
    var scrollingHandler: ((Int) -> Void)?
    var balances: [ResponseAPIWalletGetBalance]?
    
    // MARK: - Subviews
    private lazy var carousel = CircularCarousel(width: 300)
    
    init(height: CGFloat) {
        self.carouselHeight = height
        
        super.init(frame: .zero)
        
        configureForAutoLayout()
        autoSetDimension(.height, toSize: height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        addSubview(carousel)
        carousel.autoPinEdgesToSuperviewEdges()
        carousel.delegate = self
        carousel.dataSource = self
    }
    
    func reloadData() {
        carousel.reloadData()
    }
    
    func scrollTo(itemAtIndex index: Int) {
        carousel.scroll(toItemAtIndex: index, animated: true)
    }
}

extension WalletCarouselWrapper: CircularCarouselDataSource, CircularCarouselDelegate {
    func startingItemIndex(inCarousel carousel: CircularCarousel) -> Int {
        return currentIndex
    }
    
    func numberOfItems(inCarousel carousel: CircularCarousel) -> Int {
        return balances?.count ?? 0
    }
    
    func carousel(_: CircularCarousel, viewForItemAt indexPath: IndexPath, reuseView: UIView?) -> UIView {
        guard let balance = balances?[safe: indexPath.row] else {return UIView()}
        
        var view = reuseView

        if view == nil || view?.viewWithTag(1) == nil {
            view = UIView(frame: CGRect(x: 0, y: 0, width: carouselHeight, height: carouselHeight))
            let imageView = MyAvatarImageView(size: carouselHeight)
            imageView.borderColor = .appWhiteColor
            imageView.borderWidth = 2
            imageView.tag = 1
            view!.addSubview(imageView)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        }
        
        let imageView = view?.viewWithTag(1) as! MyAvatarImageView
        
        if balance.symbol == Config.defaultSymbol {
            imageView.image = UIImage(named: "tux")
        } else {
            imageView.setAvatar(urlString: balance.logo)
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
        scrollingHandler?(index)
    }
}
