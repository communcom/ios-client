//
//  MyAvatarImageView.swift
//  Commun
//
//  Created by Chung Tran on 10/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import SDWebImage

class MyAvatarImageView: MyView {
    // Nested type
    class TapGesture: UITapGestureRecognizer {
        var profileId: String?
    }
    
    var imageViewInsets: UIEdgeInsets {
        return .zero
    }
    
    var originSize: CGFloat!
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(forAutoLayout: ())
        imageView.image = UIImage(named: "empty-avatar")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    convenience init(size: CGFloat) {
        self.init(width: size, height: size)
        originSize = size
        setCornerRadius(withSize: size)
    }
    
    func setCornerRadius(withSize size: CGFloat) {
        cornerRadius = size / 2
        imageView.cornerRadius = (size - imageViewInsets.top - imageViewInsets.bottom) / 2
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .clear
        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: imageViewInsets)
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
        image = UIImage(named: "empty-avatar")
        imageView.setImageDetectGif(with: urlString, completed: completed)
    }
    
    func setAvatar(urlString: String?, namePlaceHolder: String) {
        // profile image
        if let avatarUrl = urlString {
            imageView.sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "empty-avatar")) { [weak self] (_, error, _, _) in
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
    
    func observeCurrentUserAvatar() -> Disposable {
        // avatarImage
        return UserDefaults.standard.rx
            .observe(String.self, Config.currentUserAvatarUrlKey)
            .distinctUntilChanged()
            .subscribe(onNext: {urlString in
                self.setAvatar(urlString: urlString, namePlaceHolder: Config.currentUser?.name ?? Config.currentUser?.id ?? "U")
            })
    }
    
    func setToCurrentUserAvatar() {
        setAvatar(urlString: UserDefaults.standard.string(forKey: Config.currentUserAvatarUrlKey), namePlaceHolder: Config.currentUser?.name ?? Config.currentUser?.id ?? "U")
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
    
    func addTapToViewer(with imageURL: String? = nil) {
        imageView.addTapToViewer(with: imageURL)
    }
    
    func addTapToOpenUserProfile(profileId: String?) {
        guard let profileId = profileId else {return}
        isUserInteractionEnabled = true
        let tap = TapGesture(target: self, action: #selector(openUserProfile(gesture:)))
        tap.profileId = profileId
        addGestureRecognizer(tap)
    }
    
    func addTapToOpenCommunity(profileId: String) {
        isUserInteractionEnabled = true
        let tap = TapGesture(target: self, action: #selector(openCommunity(gesture:)))
        tap.profileId = profileId
        addGestureRecognizer(tap)
    }
    
    @objc private func openUserProfile(gesture: TapGesture) {
        guard let profileId = gesture.profileId else {return}
        parentViewController?.showProfileWithUserId(profileId)
    }
    
    @objc private func openCommunity(gesture: TapGesture) {
        guard let profileId = gesture.profileId else {return}
        parentViewController?.showCommunityWithCommunityId(profileId)
    }
    
    func removeAvatar() {
        imageView.image = .placeholder
    }
}
