//
//  CMRoundedCornerShadowView.swift
//  Commun
//
//  Created by Chung Tran on 9/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMBottomToolBar: MyView {
    let mainView: UIView
    var mainViewCornerRadius: CGFloat {
        didSet { setNeedsLayout() }
    }
    
    init(mainView: UIView, shadowColor: UIColor = .shadow, radius: CGFloat = 16, offset: CGSize = CGSize(width: 0, height: -6), opacity: Float = 0.08, cornerRadius: CGFloat) {
        self.mainView = mainView
        self.mainViewCornerRadius = cornerRadius
        super.init(frame: .zero)
        addShadow(ofColor: shadowColor, radius: radius, offset: offset, opacity: opacity)
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: mainViewCornerRadius)
    }
}
