//
//  MyAvatarImageView.swift
//  Commun
//
//  Created by Chung Tran on 10/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class MyAvatarImageView: MyView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(forAutoLayout: ())
        imageView.image = .placeholder
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    convenience init(size: CGFloat) {
        self.init(width: size, height: size)
        cornerRadius = size / 2
    }
    
    override func commonInit() {
        super.commonInit()
        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    func setAvatar(urlString: String?, namePlaceHolder: String) {
        showLoader()
        // profile image
        if let avatarUrl = urlString {
            imageView.sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "ProfilePageUserAvatar")) { [weak self] (_, error, _, _) in
                self?.hideLoader()
                if (error != nil) {
                    // Placeholder image
                    self?.imageView.setNonAvatarImageWithId(namePlaceHolder)
                }
            }
        } else {
            // Placeholder image
            hideLoader()
            imageView.setNonAvatarImageWithId(namePlaceHolder)
            setNeedsLayout()
        }
    }
}
