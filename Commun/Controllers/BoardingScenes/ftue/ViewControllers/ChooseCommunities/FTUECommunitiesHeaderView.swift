//
//  FTUECommunitiesHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 4/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class FTUECommunitiesHeaderView: UICollectionReusableView {
    static let title = "get your first points".localized().uppercaseFirst
    static let description: NSAttributedString = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10 * Config.heightRatio
        let attrString = NSAttributedString(string: "subscribe to at least 3 communities and get your first Community Points".localized().uppercaseFirst, attributes: [.paragraphStyle: paragraphStyle])
        return attrString
    }()
    static let titleTextSize = 33 * Config.heightRatio
    
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
        let stackView = UIStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fill)
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 25 + 56 + 10, right: 0), excludingEdge: .bottom)
        
        let titleLabel = UILabel.with(text: FTUECommunitiesHeaderView.title, textSize: FTUECommunitiesHeaderView.titleTextSize, weight: .bold, numberOfLines: 0)
        
        let descriptionLabel = UILabel.with(textSize: 17 * Config.heightRatio, textColor: .appGrayColor, numberOfLines: 0)
        // descriptionLabel
        descriptionLabel.attributedText = FTUECommunitiesHeaderView.description
        
        stackView.addArrangedSubviews([titleLabel, descriptionLabel])
    }
    
    static var height: CGFloat {
        let width = UIScreen.main.bounds.width - 16 - 16
        
        let titleHeight = title.heightWithFont(font: .boldSystemFont(ofSize: titleTextSize), width: width)
        
        let descriptionHeight = description.heightWithWidth(width: width)
        
        return 10 + titleHeight + 16 + descriptionHeight + 16 + 44 + 10
    }
}
