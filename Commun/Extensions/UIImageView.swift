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
    
    func observeCurrentUserAvatar() -> Disposable {
        // avatarImage
        return UserDefaults.standard.rx
            .observe(String.self, Config.currentUserAvatarUrlKey)
            .distinctUntilChanged()
            .subscribe(onNext: {urlString in
                self.setAvatar(urlString: urlString, namePlaceHolder: Config.currentUser.nickName ?? "U")
            })
    }
}

extension Reactive where Base: UIImageView {
    var isEmpty: Observable<Bool> {
        return observe(UIImage.self, "image").map{ $0 == nil }
    }
}
