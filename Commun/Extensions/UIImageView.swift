//
//  UIImageView.swift
//  Commun
//
//  Created by Chung Tran on 24/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import InitialsImageView
import RxSwift
//import AppImageViewer
import CyberSwift
import SDWebImage
import SwiftyGif
import ImageViewer_swift

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
                if error != nil {
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
                 if error != nil {
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
        } else {
            showLoading(cover: false)
            downloadImageFromUrl(url, placeholderImage: image)
        }
    }

    private func downloadImageFromUrl(_ url: URL, placeholderImage: UIImage?) {
        var newUrl = url

        // resize image
        if url.host == "img.commun.com" {
            let components = url.pathComponents
            if components.count > 0 {
                newUrl = url.deletingLastPathComponent()
                newUrl = newUrl.appendingPathComponent("\(UInt(bounds.width * 1.5))x0")
                newUrl = newUrl.appendingPathComponent((components.last)!)
            }
        }

        sd_setImage(with: newUrl, placeholderImage: image) { [weak self] (_, _, _, _) in
            self?.hideLoading()
        }
    }
    
    func addTapToViewer() {
        self.isUserInteractionEnabled = true
        setupImageViewer(options: [.theme(ImageViewerTheme.dark), .closeIcon(UIImage(named: "close-x")!)])
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
        guard let url = url else { return }
        sd_setImage(with: url, placeholderImage: nil) { (image, error, _, _) in
            completion?(error, image)
        }
    }
}

extension Reactive where Base: UIImageView {
    var isEmpty: Observable<Bool> {
        return observe(UIImage.self, "image").map { $0 == nil }
            .distinctUntilChanged()
    }
}
