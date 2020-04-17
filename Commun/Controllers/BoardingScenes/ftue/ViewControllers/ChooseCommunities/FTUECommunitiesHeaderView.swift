//
//  FTUECommunitiesHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 4/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class FTUECommunitiesHeaderView: UICollectionReusableView {
    lazy var contentView = UIView(forAutoLayout: ())
    lazy var descriptionLabel = UILabel.with(textSize: 17 * Config.heightRatio, textColor: .appGrayColor, numberOfLines: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        defer {
            commonInit()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        
        // titleLabel
        let titleLabel = UILabel.with(text: "get your first points".localized().uppercaseFirst, textSize: 33 * Config.heightRatio, weight: .bold, numberOfLines: 0)
        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        
        // descriptionLabel
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10 * Config.heightRatio
        let attrString = NSAttributedString(string: "subscribe to at least 3 communities and get your first Community Points".localized().uppercaseFirst, attributes: [.paragraphStyle: paragraphStyle])
        descriptionLabel.attributedText = attrString
        contentView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 16 * Config.heightRatio)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 25 + 56 + 10)
    }
}
