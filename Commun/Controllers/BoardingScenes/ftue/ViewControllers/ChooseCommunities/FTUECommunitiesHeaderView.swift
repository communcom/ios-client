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
    lazy var descriptionLabel = UILabel.with(textSize: 17 * Config.heightRatio, textColor: .a5a7bd, numberOfLines: 0)
    var bottomConstraint: NSLayoutConstraint?
    var searchBar: UISearchBar?
    
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
        let titleLabel = UILabel.with(text: "get you first points".localized().uppercaseFirst, textSize: 33 * Config.heightRatio, weight: .bold, numberOfLines: 0)
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
        bottomConstraint = descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
    }
    
    func addSearchBar(_ sb: UISearchBar) {
        if searchBar == nil {
            searchBar = sb
            bottomConstraint?.isActive = false
            contentView.addSubview(searchBar!)
            searchBar!.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 25 * Config.heightRatio)
            searchBar!.autoPinEdge(toSuperviewEdge: .leading, withInset: -8)
            searchBar!.autoPinEdge(toSuperviewEdge: .trailing, withInset: -8)
            
            bottomConstraint = searchBar!.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        }
    }
    
    func removeSearchBar() {
        if searchBar != nil {
            bottomConstraint?.isActive = false
            searchBar?.removeFromSuperview()
            bottomConstraint = descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
            searchBar = nil
        }
    }
}
