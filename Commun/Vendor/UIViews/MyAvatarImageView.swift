//
//  MyAvatarImageView.swift
//  Commun
//
//  Created by Chung Tran on 10/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import SDWebImage

class MyAvatarImageView: MyView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(forAutoLayout: ())
        imageView.image = .placeholder
        imageView.contentMode = .scaleAspectFill
        imageView.addTapToViewer()
        return imageView
    }()
    
    convenience init(size: CGFloat) {
        self.init(width: size, height: size)
        cornerRadius = size / 2
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .clear
        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
    }
    
    var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    var gifImage: UIImage? {
        get {
            imageView.gifImage
        }
        set {
            imageView.gifImage = newValue
        }
    }
    
    func setGifImage(_ gifImage: UIImage) {
        imageView.setGifImage(gifImage)
    }
    
    func setAvatarDetectGif(with urlString: String?, placeholderName: String, completed: SDExternalCompletionBlock? = nil) {
        setNonAvatarImageWithId(placeholderName)
        imageView.setImageDetectGif(with: urlString, completed: completed)
    }
    
    func setAvatar(urlString: String?, namePlaceHolder: String) {
        showLoading()
        // profile image
        if let avatarUrl = urlString {
            imageView.sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "ProfilePageUserAvatar")) { [weak self] (_, error, _, _) in
                self?.hideLoading()
                if (error != nil) {
                    // Placeholder image
                    self?.setNonAvatarImageWithId(namePlaceHolder)
                }
            }
        } else {
            // Placeholder image
            hideLoading()
            setNonAvatarImageWithId(namePlaceHolder)
        }
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
    
    func setNonAvatarImageWithId(_ id: String) {
        if imageView.bounds.width == 0 {
            imageView.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        }
        
        var color = nonAvatarColors[id]
        if color == nil {
            repeat {
                color = UIColor.random
            } while nonAvatarColors.contains {$1==color}
            nonAvatarColors[id] = color
        }
        
        imageView.setImageForName(id, backgroundColor: color, circular: true, textAttributes: nil, gradient: false)
    }
    
    func addTapToViewer() {
        isUserInteractionEnabled = true
        imageView.addTapToViewer()
    }
}
