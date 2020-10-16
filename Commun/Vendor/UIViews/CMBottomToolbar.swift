//
//  CMRoundedCornerShadowView.swift
//  Commun
//
//  Created by Chung Tran on 9/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMRoundedCornerShadowView: MyView {
    lazy var mainView = UIView(backgroundColor: .appWhiteColor)
    lazy var stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    var mainViewCornerRadius: CGFloat {
        didSet { setNeedsLayout() }
    }
    override var backgroundColor: UIColor? {
        get { mainView.backgroundColor }
        set { mainView.backgroundColor = newValue }
    }
    
    let contentInset: UIEdgeInsets
    
    init(height: CGFloat? = nil, shadowColor: UIColor = .shadow, radius: CGFloat = 16, offset: CGSize = CGSize(width: 0, height: -6), opacity: Float = 0.08, cornerRadius: CGFloat, contentInset: UIEdgeInsets = .zero) {
        self.contentInset = contentInset
        self.mainViewCornerRadius = cornerRadius
        super.init(frame: .zero)
        defer {
            if let height = height {
                autoSetDimension(.height, toSize: height)
            }
            addShadow(ofColor: shadowColor, radius: radius, offset: offset, opacity: opacity)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        configureForAutoLayout()
        mainView.configureForAutoLayout()
        
        addSubview(mainView)
        mainView.autoPinEdgesToSuperviewEdges()
        
        mainView.addSubview(stackView)
        pinStackView()
    }
    
    func pinStackView() {
        stackView.autoPinEdgesToSuperviewEdges(with: contentInset)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners()
    }
    
    func roundCorners() {
        mainView.cornerRadius = mainViewCornerRadius
    }
}

class CMBottomToolbar: CMRoundedCornerShadowView {
    override func roundCorners() {
        mainView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: mainViewCornerRadius)
    }
}
