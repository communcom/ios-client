//
//  UsersStackView.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class UsersStackView: UIView {
    // MARK: - Properties
    let maxNumberOfAvatars = 5
    
    // MARK: - Subviews
    lazy var avatarsStackView: UIStackView = {
        let stackView = UIStackView(height: 34)
        stackView.semanticContentAttribute = .forceRightToLeft
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = -10
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        addSubview(avatarsStackView)
        avatarsStackView.autoPinEdge(toSuperviewEdge: .leading)
        avatarsStackView.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
    
    func setUp(with friends: [ResponseAPIContentResolveProfile]) {
        // remove all labels
        for subview in subviews {
            if subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        
        // remove stacks
        avatarsStackView.removeArrangedSubviews()
        avatarsStackView.removeConstraintToSuperView(withAttribute: .trailing)
        
        // add avatars
        let text: String
        if friends.count <= 5 {
            for friend in friends {
                let imageView = UIImageView(width: 34, height: 34)
                imageView.layer.masksToBounds = true
                imageView.layer.borderWidth = 2
                imageView.layer.borderColor = UIColor.white.cgColor
                imageView.layer.cornerRadius = 17
                avatarsStackView.addArrangedSubview(imageView)
                imageView.setAvatar(urlString: friend.avatarUrl, namePlaceHolder: friend.username)
            }
            text = "\(friends.count)"
        }
        
        else {
            for i in 0..<3 {
                let imageView = UIImageView(width: 34, height: 34)
                imageView.layer.masksToBounds = true
                imageView.layer.borderWidth = 2
                imageView.layer.borderColor = UIColor.white.cgColor
                imageView.layer.cornerRadius = 17
                avatarsStackView.addArrangedSubview(imageView)
                imageView.setAvatar(urlString: friends[i].avatarUrl, namePlaceHolder: friends[i].username)
            }
            text = "+\(Double(friends.count - 3).kmFormatted)"
        }
        
        let label = UILabel.with(text: text, textSize: 15, weight: .bold)
        addSubview(label)
        label.autoPinEdge(.leading, to: .trailing, of: avatarsStackView, withOffset: 5)
        label.autoAlignAxis(.horizontal, toSameAxisOf: avatarsStackView)
        label.autoPinEdge(toSuperviewEdge: .trailing)
    }
    
    // for testing purpose
    func setNumberOfAvatars(i: Int) {
        // remove all labels
        for subview in subviews {
            if subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        
        // remove stacks
        avatarsStackView.removeArrangedSubviews()
        avatarsStackView.removeConstraintToSuperView(withAttribute: .trailing)
        
        // add avatars
        if i <= 5 {
            for _ in 0..<i {
                let imageView = UIImageView(width: 34, height: 34)
                imageView.layer.masksToBounds = true
                imageView.layer.borderWidth = 2
                imageView.layer.borderColor = UIColor.white.cgColor
                imageView.layer.cornerRadius = 17
                imageView.image = UIImage(named: "ProfilePageCover")
                avatarsStackView.addArrangedSubview(imageView)
            }
            avatarsStackView.autoPinEdge(toSuperviewEdge: .trailing)
        }
        else {
            for _ in 0..<3 {
                let imageView = UIImageView(width: 34, height: 34)
                imageView.layer.masksToBounds = true
                imageView.layer.borderWidth = 2
                imageView.layer.borderColor = UIColor.white.cgColor
                imageView.layer.cornerRadius = 17
                imageView.image = UIImage(named: "ProfilePageCover")
                avatarsStackView.addArrangedSubview(imageView)
            }
            
            let label1 = UILabel.with(text: "+\(Double(i - 3).kmFormatted)", textSize: 15, weight: .bold)
            let label2 = UILabel.with(text: "friends".localized().uppercaseFirst, textSize: 12, weight: .bold, textColor: .gray)
            
            addSubview(label1)
            label1.autoPinEdge(.leading, to: .trailing, of: avatarsStackView, withOffset: 5)
            label1.autoAlignAxis(.horizontal, toSameAxisOf: avatarsStackView)
            
            addSubview(label2)
            label2.autoPinEdge(.leading, to: .trailing, of: label1, withOffset: 5)
            label2.autoPinEdge(.bottom, to: .bottom, of: label1, withOffset: -1)
            label2.autoPinEdge(toSuperviewEdge: .trailing)
        }
    }
}
