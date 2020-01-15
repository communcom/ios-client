//
//  WalletCarousel.swift
//  Commun
//
//  Created by Chung Tran on 1/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import CircularCarousel

class WalletCarousel: CircularCarousel {
    // MARK: - Constants
    var carouselHeight: CGFloat
    
    // MARK: - Subviews
    lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        return gradient
    }()
    
    // MARK: - Methods
    init(height: CGFloat) {
        carouselHeight = height
        super.init(frame: .zero)
        configureForAutoLayout()
        autoSetDimension(.height, toSize: height)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        layer.addSublayer(gradient)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}
