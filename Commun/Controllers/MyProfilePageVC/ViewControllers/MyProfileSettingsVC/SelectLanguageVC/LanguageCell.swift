//
//  LanguageCell.swift
//  Commun
//
//  Created by Chung Tran on 4/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class LanguageCell: MyTableViewCell {
    // MARK: - Properties
    
    // MARK: - Subviews
    lazy var flagImageView = UIImageView(width: 35, height: 35, cornerRadius: 17.5)
    lazy var nameLabel = UILabel.with(numberOfLines: 0)
    lazy var checkMark = UIImageView(width: 20, height: 20, cornerRadius: 10, imageNamed: "round-checkmark")
    lazy var separator = UIView(height: 1, backgroundColor: .f3f5fa)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        selectionStyle = .none
        
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
        
        contentView.addSubview(separator)
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        separator.autoPinEdge(.top, to: .bottom, of: stackView, withOffset: 12)
        
        stackView.addArrangedSubviews([flagImageView, nameLabel, checkMark])
    }
    
    func setUp(with language: SelectLanguageVC.Language) {
        flagImageView.image = UIImage(named: language.imageName)
        let localizedName = (language.name + " language").localized().uppercaseFirst
        nameLabel.attributedText = NSMutableAttributedString()
            .text(language.name.uppercaseFirst, size: 15, weight: .semibold)
            .text("\n")
            .text(localizedName, size: 12, weight: .medium, color: .a5a7bd)
            .withParagraphStyle(lineSpacing: 3)
        checkMark.isHidden = !language.isSelected
    }
}
