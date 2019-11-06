//
//  ContentHuggingScrollView.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class ContentHuggingScrollView: UIScrollView {
    // MARK: - Subviews
    lazy var contentView = UIView(forAutoLayout: ())
    var axis: NSLayoutConstraint.Axis = .horizontal
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    convenience init(axis: NSLayoutConstraint.Axis) {
        self.init(forAutoLayout: ())
        self.axis = axis
    }
    
    func commonInit() {
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        if axis == .horizontal {
            contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        }
        else {
            contentView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        }
    }
}
