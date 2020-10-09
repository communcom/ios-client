//
//  UIImage.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension UIImageView {
    public convenience init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        backgroundColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil,
        imageNamed: String? = nil,
        contentMode: UIImageView.ContentMode? = nil
    ) {
        self.init(forAutoLayout: ())
        if let width = width {
            autoSetDimension(.width, toSize: width)
        }
        if let height = height {
            autoSetDimension(.height, toSize: height)
        }
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if let cornerRadius = cornerRadius {
            self.cornerRadius = cornerRadius
        }
        
        if let imageNamed = imageNamed {
            image = UIImage(named: imageNamed)
        }
        
        if let contentMode = contentMode {
            self.contentMode = contentMode
        }
    }
    
    static func circle(size: CGFloat, backgroundColor: UIColor? = nil, imageName: String? = nil) -> UIImageView {
        let imageView = UIImageView(forAutoLayout: ())
        imageView.autoSetDimensions(to: CGSize(width: size, height: size))
        if let backgroundColor = backgroundColor {
            imageView.backgroundColor = backgroundColor
        }
        
        imageView.cornerRadius = size / 2
        if let imageName = imageName {
            imageView.image = UIImage(named: imageName)
        }
        return imageView
    }
}
