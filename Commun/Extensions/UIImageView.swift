//
//  UIImageView.swift
//  Commun
//
//  Created by Chung Tran on 24/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import UIImageView_Letters
import RxSwift
import AppImageViewer
import CyberSwift

fileprivate var nonAvatarColors = [String: UIColor]()

extension UIImageView {
    func setNonAvatarImageWithId(_ id: String) {
        var color = nonAvatarColors[id]
        if color == nil {
            repeat {
                color = UIColor.random
            } while nonAvatarColors.contains {$1==color}
            nonAvatarColors[id] = color
        }
        
        setImageWith(id, color: color)
    }
    
    func setAvatar(urlString: String?, namePlaceHolder: String) {
        // profile image
        if let avatarUrl = urlString {
            sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "ProfilePageUserAvatar")) { (_, error, _, _) in
                if (error != nil) {
                    // Placeholder image
                    self.setNonAvatarImageWithId(namePlaceHolder)
                }
            }
        } else {
            // Placeholder image
            setNonAvatarImageWithId(namePlaceHolder)
        }
    }
    
    func addTapToViewer() {
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(openViewer(gesture:)))
        addGestureRecognizer(tap)
    }
    
    @objc func openViewer(gesture: UITapGestureRecognizer) {
        guard let image = image else {return}
        let appImage = ViewerImage.appImage(forImage: image)
        let viewer = AppImageViewer(originImage: image, photos: [appImage], animatedFromView: self)
        parentViewController?.present(viewer, animated: false, completion: nil)
    }
    
    func observeCurrentUserAvatar() -> Disposable {
        // avatarImage
        return UserDefaults.standard.rx
            .observe(String.self, Config.currentUserAvatarUrlKey)
            .distinctUntilChanged()
            .subscribe(onNext: {urlString in
                self.setAvatar(urlString: urlString, namePlaceHolder: Config.currentUser?.id ?? "U")
            })
    }
    
    class func drawCircleLine(size: CGSize, color: UIColor = .black) -> UIImage {
        let lineWidth: CGFloat = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size.height, height: size.height))
        
        return renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
            ctx.cgContext.setStrokeColor(color.cgColor)
            ctx.cgContext.setLineWidth(lineWidth)
            
            let rectangle = CGRect(x:           lineWidth,
                                   y:           lineWidth,
                                   width:       size.height - lineWidth * 2,
                                   height:      size.height - lineWidth * 2)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
    }
}


extension Reactive where Base: UIImageView {
    var isEmpty: Observable<Bool> {
        return observe(UIImage.self, "image").map{ $0 == nil }
    }
}
