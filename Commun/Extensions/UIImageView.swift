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
import ASSpinnerView

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
                    self?.image = UIImage(named: "empty-avatar")
                }
            }
        } else {
            // Placeholder image
            image = UIImage(named: "empty-avatar")
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

    func setImageDetectGif(with urlString: String?, completed: SDExternalCompletionBlock? = nil, customWidth: CGFloat? = nil) {
        guard let urlString = urlString,
            let url = URL(string: urlString)
        else {return}
        if urlString.lowercased().ends(with: ".gif") {
            // add spinnerView
            let size = (height > 76 ? 60: height-16)
            let spinnerView = ASSpinnerView(width: size, height: size)
            spinnerView.spinnerLineWidth = size/10
            spinnerView.spinnerDuration = 0.3
            spinnerView.spinnerStrokeColor = UIColor.white.cgColor
            
            setGifFromURL(url, customLoader: spinnerView)
        } else {
            downloadImageFromUrl(url, placeholderImage: image, customWidth: customWidth)
        }
    }

    private func downloadImageFromUrl(_ url: URL, placeholderImage: UIImage?, customWidth: CGFloat? = nil) {
        var newUrl = url
        var placeholderUrl: URL?
        var width = bounds.width
        showBlur(false)

        if let customWidth = customWidth {
            width = customWidth
        }

        // resize image
        if url.host == "img.commun.com" {
            let components = url.pathComponents
            if components.count > 0 {
                newUrl = url.deletingLastPathComponent()
                placeholderUrl = newUrl.appendingPathComponent("20x0")
                placeholderUrl = placeholderUrl?.appendingPathComponent((components.last)!)
                newUrl = newUrl.appendingPathComponent("\(UInt(width * 2))x0")
                newUrl = newUrl.appendingPathComponent((components.last)!)
            }
        }

        showLoading(cover: false, spinnerColor: .white)

        if let placeholderUrl = placeholderUrl {
            self.showBlur(true)
            self.sd_setImage(with: placeholderUrl, placeholderImage: self.image) { [weak self] (image, _, _, _) in
                DispatchQueue.main.async {
                    self?.image = image
                    self?.sd_setImage(with: newUrl, placeholderImage: image) { [weak self] (image, _, _, _) in
                        DispatchQueue.main.async {
                            self?.showBlur(false)
                            self?.hideLoading()
                            if image == nil {
                                self?.sd_setImageCachedError(with: newUrl, completion: nil)
                            }
                        }
                    }
                }

            }
        } else {
            self.sd_setImage(with: newUrl, placeholderImage: self.image) { [weak self] (_, _, _, _) in
                self?.hideLoading()
            }
        }

    }

    private func showBlur(_ show: Bool) {
        let tag = ViewTag.blurView.rawValue
        if !UIAccessibility.isReduceTransparencyEnabled {
            self.viewWithTag(tag)?.removeFromSuperview()
            if show {
                let blurEffect = UIBlurEffect(style: .light)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.tag = tag
                //always fill the view
                blurEffectView.frame = self.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                addSubview(blurEffectView)
            }
        }
        if let loadingView = viewWithTag(ViewTag.loadingView.rawValue) {
            self.bringSubviewToFront(loadingView)
        }
    }
    
    func addTapToViewer() {
        self.isUserInteractionEnabled = true
       
        setupImageViewer(options: [
            .theme(ImageViewerTheme.dark),
            .closeIcon(UIImage(named: "close-x")!),
            .rightNavItemIcon(UIImage(named: "image-share")!, delegate: self)
        ])
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

extension UIImageView: RightNavItemDelegate {
    public func imageViewer(_ imageViewer: ImageCarouselViewController, didTapRightNavItem index: Int) {
        guard let image = image else {return}
        ShareHelper.share(image: image)
    }
}
