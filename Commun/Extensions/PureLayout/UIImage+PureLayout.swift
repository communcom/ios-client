//
//  UIImage.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension UIImageView {
    static func circle(size: CGFloat, imageName: String? = nil) -> UIImageView {
        let imageView = UIImageView(forAutoLayout: ())
        imageView.autoSetDimensions(to: CGSize(width: size, height: size))
        imageView.backgroundColor = .orange
        imageView.cornerRadius = size / 2
        if let imageName = imageName {
            imageView.image = UIImage(named: imageName)
        }
        return imageView
    }
}
