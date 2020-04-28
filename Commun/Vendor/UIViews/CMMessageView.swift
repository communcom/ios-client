//
//  CMMessageView.swift
//  Commun
//
//  Created by Chung Tran on 4/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMMessageView: MyView {
    let arrowSize: CGFloat = 8
    
    weak var senderView: UIView? {
        didSet {
            guard let senderView = senderView else {return}
            arrowView.removeFromSuperview()
            insertSubview(arrowView, at: 0)
            arrowView.autoPinEdge(toSuperviewEdge: .bottom)
            arrowView.centerXAnchor.constraint(equalTo: senderView.centerXAnchor).isActive = true
            setNeedsLayout()
        }
    }
    
    lazy var contentView = UIView(backgroundColor: .appMainColor, cornerRadius: 22)
    
    lazy var arrowView: UIView = {
        let arrowView = UIView(width: arrowSize * 2, height: arrowSize * 2, backgroundColor: .appMainColor, cornerRadius: 3)
        arrowView.transform = arrowView.transform.rotated(by: 45 / 180.0 * CGFloat.pi)
        return arrowView
    }()
    
    override func commonInit() {
        super.commonInit()
        configureForAutoLayout()
        
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: arrowSize - 2, right: 0))
        
        addShadow(ofColor: UIColor.colorSupportDarkMode(defaultColor: UIColor(red: 176, green: 176, blue: 204)!, darkColor: .black), radius: 25, offset: CGSize(width: 0, height: 10), opacity: 0.25)
    }
}
