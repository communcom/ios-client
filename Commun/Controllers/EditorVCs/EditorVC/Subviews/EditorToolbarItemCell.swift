//
//  EditorToolbarItemCell.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class EditorToolbarItemCell: UICollectionViewCell {
    var itemSize: CGFloat = 35
    static let padding: CGFloat = 14
    static let separatorSpace: CGFloat = 10
    static let fontSize: CGFloat = 15
    static let fontWeight = UIFont.Weight.semibold
    
    var itemImageView = UIImageView(forAutoLayout: ())
    var descriptionLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        contentView.cornerRadius = itemSize / 2
        contentView.addSubview(itemImageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel?.removeFromSuperview()
        contentView.removeAllConstraints()
        itemImageView.removeAllConstraints()
    }
    
    func setUp(item: EditorToolbarItem) {
        if item == .setColor {
            contentView.backgroundColor = item.other as? UIColor
            itemImageView.image = nil
            return
        }
        
        // enabled state
        var textColor = UIColor(hexString: "#A5A7BD")!
        if item.isHighlighted {
            contentView.backgroundColor = .appMainColor
            textColor = .white
        }
        else {
            contentView.backgroundColor = UIColor(hexString: "#F3F5FA")
        }
        itemImageView.tintColor = textColor
        
        // icon
        itemImageView.image = UIImage(named: item.icon)
        itemImageView.autoSetDimensions(to: item.iconSize)
        itemImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        // optional description
        if let desc = item.description {
            itemImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: EditorToolbarItemCell.padding)
            
            descriptionLabel = UILabel.with(text: desc.localized().uppercaseFirst, textSize: EditorToolbarItemCell.fontSize, weight: EditorToolbarItemCell.fontWeight, textColor: textColor)
            contentView.addSubview(descriptionLabel!)
            descriptionLabel!.autoPinEdge(.leading, to: .trailing, of: itemImageView, withOffset: EditorToolbarItemCell.separatorSpace)
            descriptionLabel!.autoAlignAxis(toSuperviewAxis: .horizontal)
            descriptionLabel!.autoPinEdge(toSuperviewEdge: .trailing, withInset: EditorToolbarItemCell.padding)
        }
        else {
            itemImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        }
    }
}
