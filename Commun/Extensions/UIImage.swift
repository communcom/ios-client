//
//  File.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
      let rect = CGRect(origin: .zero, size: size)
      UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
      color.setFill()
      UIRectFill(rect)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      guard let cgImage = image?.cgImage else { return nil }
      self.init(cgImage: cgImage)
    }
    
    static var placeholder: UIImage {
        return UIImage(named: "ProfilePageCover")!
    }
    
    public func resizeWithSideMax(_ maxSide: CGFloat = 1280) -> UIImage? {
        var image = self

        if size.width > maxSide || size.height > maxSide {
            let proportion = size.width >= size.height ? size.width / maxSide : size.height / maxSide
            let finalRect = CGRect(x: 0, y: 0, width: size.width / proportion, height: size.height / proportion)
            UIGraphicsBeginImageContextWithOptions(finalRect.size, false, 1.0)
            draw(in: finalRect)
            image = UIGraphicsGetImageFromCurrentImageContext() ?? self
            UIGraphicsEndImageContext()
        }

        if let imageData = image.jpegData(compressionQuality: 0.6) {
            let finalImage = UIImage(data: imageData) ?? image
            return finalImage
        }

        return nil
    }
}
