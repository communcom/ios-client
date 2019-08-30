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
    
    func sd_setImageCachedError(with url: URL, completion: ((Error?) -> Void)?) {
        showLoader()
        sd_setImage(with: url) { [weak self] (image, error, _, _) in
            self?.hideLoader()
            if error != nil {
                self?.image = UIImage(named: "image-not-found")
            }
            completion?(error)
        }
    }
}


extension Reactive where Base: UIImageView {
    var isEmpty: Observable<Bool> {
        return observe(UIImage.self, "image").map{ $0 == nil }
            .distinctUntilChanged()
    }
}
