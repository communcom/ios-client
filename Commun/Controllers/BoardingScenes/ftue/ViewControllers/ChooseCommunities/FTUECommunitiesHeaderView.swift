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
    
    static var additionalSpaceToSearchBar: CGFloat {
        var additionalHeight: CGFloat = 0
        switch UIDevice.current.screenType {
        case .iPhones_4_4S, .iPhones_6_6s_7_8:
            break
        case .iPhones_5_5s_5c_SE:
            additionalHeight = 4
        case .iPhones_6Plus_6sPlus_7Plus_8Plus, .iPhones_X_XS:
            additionalHeight = 16
        case .iPhone_XR_11:
            additionalHeight = 20
        case .iPhone_XSMax_ProMax:
            additionalHeight = 16
        case .iPhone_11Pro:
            break
        case .unknown:
            break
        }
        return additionalHeight
    }
}
