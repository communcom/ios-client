//
//  GradientProgressBar.swift
//  Commun
//
//  Created by Chung Tran on 12/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class GradientProgressBar: MyView {
    let padding: CGFloat = 2
    // MARK: - Properties
    var actualHeight: CGFloat
    var progress: CGFloat = 0 {
        didSet {
            layoutIfNeeded()
            animate()
        }
    }
    var progressViewWidthConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var progressView = UIView(forAutoLayout: ())
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        // make sure to use .cgColor
        gradientLayer.colors = [UIColor(hexString: "#B1F4E0")!.cgColor, UIColor(hexString: "#4EDBB0")!.cgColor]
        return gradientLayer
    }()
    
    // MARK: - Methods
    init(height: CGFloat) {
        self.actualHeight = height
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        
        configureForAutoLayout()
        autoSetDimension(.height, toSize: actualHeight)
        backgroundColor = UIColor.appWhiteColor.withAlphaComponent(0.1)
        cornerRadius = actualHeight / 2
        
        progressView.cornerRadius = (actualHeight - padding * 2) / 2
        progressView.autoSetDimension(.height, toSize: actualHeight - padding * 2)
        
        addSubview(progressView)
        progressView.autoPinEdge(toSuperviewEdge: .leading, withInset: padding)
        progressView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        progressViewWidthConstraint = progressView.autoSetDimension(.width, toSize: progress)

        progressView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func animate() {
        let newWidth = (bounds.width - padding * 2) * progress
        progressViewWidthConstraint?.constant = newWidth
        
        UIView.animate(withDuration: 1) {
            self.layoutIfNeeded()
            self.gradientLayer.frame = self.progressView.bounds
        }
    }
}
