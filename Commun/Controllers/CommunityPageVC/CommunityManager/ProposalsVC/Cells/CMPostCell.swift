//
//  CMPostCell.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMPostCell: MyTableViewCell {
    lazy var stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    lazy var metaView = PostMetaView(height: 40.0)
    lazy var postStatsView = PostStatsView(forAutoLayout: ())
    
    override func setUpViews() {
        super.setUpViews()
        backgroundColor = .appWhiteColor
        selectionStyle = .none
        
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        setUpStackView()
    }
    
    func setUpStackView() {
        stackView.addArrangedSubviews([
            metaView,
            createContentView(),
            postStatsView
        ])
    }
    
    func createContentView() -> UIView {
        fatalError("for overriding")
    }
}
