//
//  UIImageView.swift
//  Commun
//
//  Created by Chung Tran on 24/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import InitialsImageView
import RxSwift
import AppImageViewer
import CyberSwift
import SDWebImage
import SwiftyGif

var nonAvatarColors = [String: UIColor]()

extension UIImageView {
    func setNonAvatarImageWithId(_ id: String) {
        frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        var color = nonAvatarColors[id]
        if color == nil {
            repeat {
                color = UIColor.random
            } while nonAvatarColors.contains {$1==color}
            nonAvatarColors[id] = color
        }
        
        setImageForName(id, backgroundColor: color, circular: true, textAttributes: nil, gradient: false)
    }
    
    func setAvatar(urlString: String?, namePlaceHolder: String) {
        // profile image
        if let avatarUrl = urlString {
            sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "ProfilePageUserAvatar")) { [weak self] (_, error, _, _) in
                if (error != nil) {
                    // Placeholder image
                    self?.setNonAvatarImageWithId(namePlaceHolder)
                }
            }
        } else {
            // Placeholder image
            setNonAvatarImageWithId(namePlaceHolder)
        }
    }
    
    func setCover(urlString: String?, namePlaceHolder: String = "ProfilePageCover") {
         // Cover image
         if let coverUrlValue = urlString {
             sd_setImage(with: URL(string: coverUrlValue), placeholderImage: UIImage(named: namePlaceHolder)) { [weak self] (_, error, _, _) in
                 if (error != nil) {
                     // Placeholder image
                     self?.image = .placeholder
                 }
             }
         } else {
             // Placeholder image
             self.image = .placeholder
         }
     }

    func setImageDetectGif(with urlString: String?, completed: SDExternalCompletionBlock? = nil) {
        guard let urlString = urlString,
            let url = URL(string: urlString)
        else {return}
        if urlString.lowercased().ends(with: ".gif") {
            setGifFromURL(url)
        }
        else {
            showLoading(cover: false)
            sd_setImage(with: url, placeholderImage: image) { [weak self] (image, error, _, _) in
                self?.hideLoading()
            }
        }
    }
    
    func addTapToViewer() {
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(openViewer(gesture:)))
        addGestureRecognizer(tap)
    }
    
    @objc func openViewer(gesture: UITapGestureRecognizer?) {
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
                self.setAvatar(urlString: urlString, namePlaceHolder: Config.currentUser?.name ?? "U")
            })
    }
    
    func sd_setImageCachedError(with url: URL?, completion: ((Error?, UIImage?) -> Void)?) {
//        showLoading()
        guard let url = url else {
            image = UIImage(named: "image-not-found")
            return
        }
        sd_setImage(with: url, placeholderImage: UIImage(named: "image-loading")) { [weak self] (image, error, _, _) in
//            self?.hideLoading()
            if error != nil {
                self?.image = UIImage(named: "image-not-found")
            }
            completion?(error, image)
        }
    }
}


extension Reactive where Base: UIImageView {
    var isEmpty: Observable<Bool> {
        return observe(UIImage.self, "image").map{ $0 == nil }
            .distinctUntilChanged()
    }
}
