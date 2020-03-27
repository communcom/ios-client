//
//  UIScrollView.swift
//  Commun
//
//  Created by Chung Tran on 07/06/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension UIScrollView {
    var isUserScrolling: Bool {
        isTracking || isDragging || isDecelerating
    }
    
    func scrollsToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        setContentOffset(bottomOffset, animated: true)
    }
    
    func scrollTo(_ frame: CGRect) {
        scrollRectToVisible(frame, animated: true)
//        setContentOffset(.zero, animated: true)
    }
    
    func scrollToTop() {
         let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
         setContentOffset(desiredOffset, animated: true)
    }
    
    func cropImageView(
        _ imageView: UIImageView,
        maxSize: CGFloat = 1280,
        disableHorizontal: Bool = false
    ) -> UIImage? {
        guard let originalImage = imageView.image else {
            return nil
        }
        
        let displayWidth = bounds.width
        let displayHeight = bounds.height
        
        var proportion = originalImage.size.width < originalImage.size.height ? originalImage.size.width / displayWidth : originalImage.size.height / displayHeight
        
        if disableHorizontal {
            proportion = originalImage.size.width / displayWidth
        }
        
        proportion /= zoomScale
        
        let offsetX = contentOffset.x
        let offsetY = contentOffset.y
        
        var finalRect = CGRect(
            x: offsetX,
            y: offsetY,
            width: displayWidth,
            height: bounds.height
        )
        
        finalRect.origin.x *= proportion
        finalRect.origin.y *= proportion
        finalRect.size.width *= proportion
        finalRect.size.height *= proportion
        
        // crop
        let imageRef: CGImage = (originalImage.cgImage?.cropping(to: finalRect))!
        let image: UIImage = UIImage(cgImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image.resize(maxSize)
    }
}

extension Reactive where Base: UIScrollView {
    var willDragDown: Observable<Bool> {
        return Observable.merge(
            willEndDragging.map { $0.velocity.y >= 0 },
            contentOffset.map {($0.y + self.base.contentInset.top) == 0 }.filter {$0}.map {!$0}
        )
    }
}
