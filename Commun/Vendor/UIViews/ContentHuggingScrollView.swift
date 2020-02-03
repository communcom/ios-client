//
//  ContentHuggingScrollView.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class ContentHuggingScrollView: UIScrollView {
    // MARK: - Subviews
    lazy var contentView = UIView(forAutoLayout: ())
    var axis: NSLayoutConstraint.Axis = .horizontal
    
    // MARK: - Methods
    init(axis: NSLayoutConstraint.Axis, contentInset: UIEdgeInsets = .zero) {
        self.axis = axis
        super.init(frame: .zero)
        self.contentInset = contentInset
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        configureForAutoLayout()
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        if axis == .horizontal {
            contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        } else {
            contentView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        }
    }
}
