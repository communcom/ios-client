//
//  UsersStackView.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class UsersStackView: MyView {
    // MARK: - Properties
    let maxNumberOfAvatars = 3
    var textColor = UIColor.appBlackColor {
        didSet {
            label.textColor = textColor
        }
    }
    
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
    
    lazy var label = UILabel.with(textSize: 15, weight: .bold)
    
    override func commonInit() {
        super.commonInit()
        addSubview(avatarsStackView)
        avatarsStackView.autoPinEdge(toSuperviewEdge: .leading)
        avatarsStackView.autoAlignAxis(toSuperviewAxis: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    // MARK: - Methods
    func setUp(with friends: [ResponseAPIContentGetProfile]) {
        // remove all labels
        for subview in subviews where subview is UILabel {
            subview.removeFromSuperview()
        }
        
        // remove stacks
        avatarsStackView.removeArrangedSubviews()
        avatarsStackView.removeConstraintToSuperView(withAttribute: .trailing)
        
        // add avatars
        let text: String
        if friends.count <= maxNumberOfAvatars {
            for friend in friends {
                let imageView = MyAvatarImageView(size: 34)
                imageView.layer.borderWidth = 2
                imageView.layer.borderColor = UIColor.appWhiteColor.cgColor
                imageView.addTapToOpenUserProfile(profileId: friend.userId)
                avatarsStackView.addArrangedSubview(imageView)
                imageView.setAvatar(urlString: friend.avatarUrl)
            }
            text = "\(friends.count.kmFormatted)"
        } else {
            for i in 0..<maxNumberOfAvatars {
                let imageView = MyAvatarImageView(size: 34)
                imageView.layer.borderWidth = 2
                imageView.layer.borderColor = UIColor.appWhiteColor.cgColor
                imageView.addTapToOpenUserProfile(profileId: friends[i].userId)
                avatarsStackView.addArrangedSubview(imageView)
                imageView.setAvatar(urlString: friends[i].avatarUrl)
            }
            text = "+\((friends.count - maxNumberOfAvatars).kmFormatted)"
        }
        
        label.text = text
        addSubview(label)
        label.autoPinEdge(.leading, to: .trailing, of: avatarsStackView, withOffset: 5)
        label.autoAlignAxis(.horizontal, toSameAxisOf: avatarsStackView)
        label.autoPinEdge(toSuperviewEdge: .trailing)
    }
    
    // MARK: - Test
    /// Mocking method
    func setNumberOfAvatars(i: Int) {
        // remove all labels
        for subview in subviews where subview is UILabel {
            subview.removeFromSuperview()
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
                imageView.layer.borderColor = UIColor.appWhiteColor.cgColor
                imageView.layer.cornerRadius = 17
                imageView.image = UIImage(named: "ProfilePageCover")
                avatarsStackView.addArrangedSubview(imageView)
            }
            avatarsStackView.autoPinEdge(toSuperviewEdge: .trailing)
        } else {
            for _ in 0..<3 {
                let imageView = UIImageView(width: 34, height: 34)
                imageView.layer.masksToBounds = true
                imageView.layer.borderWidth = 2
                imageView.layer.borderColor = UIColor.appWhiteColor.cgColor
                imageView.layer.cornerRadius = 17
                imageView.image = UIImage(named: "ProfilePageCover")
                avatarsStackView.addArrangedSubview(imageView)
            }
            
            let label1 = UILabel.with(text: "+\((i - 3).kmFormatted)", textSize: 15, weight: .bold)
            let label2 = UILabel.with(text: String(format: NSLocalizedString("friend-count", comment: ""), (i - 3)), textSize: 12, weight: .bold, textColor: .gray)

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
