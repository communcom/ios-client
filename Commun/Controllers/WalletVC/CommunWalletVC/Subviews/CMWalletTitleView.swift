//
//  CMWalletTitleView.swift
//  Commun
//
//  Created by Chung Tran on 4/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMWalletTitleView: MyView {
    let unselectedBackgroundColor = UIColor.white.withAlphaComponent(0.2)
    let unselectedTintColor = UIColor.white
    let selectedBackgroundColor = UIColor.white
    let selectedTintColor = UIColor.appMainColor
    
    lazy var logoView: UIView = {
        let view = UIView(width: 40, height: 40, backgroundColor: unselectedBackgroundColor, cornerRadius: 20)
        view.addSubview(slash)
        slash.autoCenterInSuperview()
        return view
    }()
    lazy var slash = UILabel.with(text: "/", textSize: 20, weight: .bold, textColor: unselectedTintColor)
    lazy var usdView: UIView = {
        let view = UIView(width: 40, height: 40, backgroundColor: unselectedBackgroundColor, cornerRadius: 20)
        view.addSubview(usdSymbol)
        usdSymbol.autoCenterInSuperview()
        return view
    }()
    lazy var usdSymbol = UILabel.with(text: "$", textSize: 24, weight: .semibold, textColor: unselectedTintColor)
    
    override func commonInit() {
        super.commonInit()
        addSubview(usdView)
        usdView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        addSubview(logoView)
        logoView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .leading)
        
        logoView.autoPinEdge(.leading, to: .trailing, of: usdView, withOffset: 10)
    }
    
    func setShowUSD(_ show: Bool) {
        if show {
            logoView.backgroundColor = unselectedBackgroundColor
            slash.textColor = unselectedTintColor
            
            usdView.backgroundColor = selectedBackgroundColor
            usdSymbol.textColor = selectedTintColor
        } else {
            logoView.backgroundColor = selectedBackgroundColor
            slash.textColor = selectedTintColor
            
            usdView.backgroundColor = unselectedBackgroundColor
            usdSymbol.textColor = unselectedTintColor
        }
    }
}
