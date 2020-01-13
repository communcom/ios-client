//
//  ProfileEditViewController+Actions.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 19.11.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyGif

extension ProfileEditViewController {
    @objc func changeCoverBtnDidTouch(_ sender: Any) {
        openActionSheet(cover: true)
    }
    
    @objc func changeAvatarBtnDidTouch(_ sender: Any) {
        openActionSheet(cover: false)
    }

    // MARK: - Covers + Avatar
    func openActionSheet(cover: Bool) {
        showCommunActionSheet(
            title: String(format: "%@ %@", "change".localized().uppercaseFirst, (cover ? "cover photo" : "profile photo").localized()),
            actions: [
                CommunActionSheet.Action(
                    title: "choose from gallery".localized().uppercaseFirst,
                    icon: UIImage(named: "photo_solid"),
                    handle: {[unowned self] in
                        cover ? self.onUpdateCover() : self.onUpdateAvatar()
                }),
                CommunActionSheet.Action(
                    title: String(format: "%@ %@", "delete current".localized().uppercaseFirst, (cover ? "cover photo" : "profile photo").localized()),
                    icon: UIImage(named: "delete"),
                    handle: {[unowned self] in
                        cover ? self.onUpdateCover(delete: true) : self.onUpdateAvatar(delete: true)
                    },
                    tintColor: .red
                )
        ])
    }
    
    func onUpdateCover(delete: Bool = false) {
        // Save originalImage for reverse when update failed
        let originalImage = self.coverImageView.image
        let originGif = self.avatarView.gifImage
        
        // If deleting
        if delete {
            self.coverImageView.image = .placeholder
           
            NetworkService.shared.updateMeta(params: ["cover_url": ""])
                .subscribe(onError: {[weak self] error in
                    if let gif = originGif {
                        self?.coverImageView.setGifImage(gif)
                    } else {
                        self?.coverImageView.image = originalImage
                    }
                    
                    self?.showError(error)
                })
                .disposed(by: DisposeBag())
            return
        }
        
        // If updating
        let pickerVC = SinglePhotoPickerVC()
        pickerVC.completion = { image in
            let coverEditVC = controllerContainer.resolve(ProfileEditCoverVC.self)!
            
            pickerVC.present(coverEditVC, animated: true, completion: {
                coverEditVC.coverImage.image = image
            })
            
            coverEditVC.didSelectImage
                .do(onNext: { image in
                    self.coverImageView.image = image
                    coverEditVC.dismiss(animated: true, completion: {
                        pickerVC.dismiss(animated: true, completion: nil)
                    })
                })
                // Upload image
                .flatMap {NetworkService.shared.uploadImage($0)}
                // Save to db
                .flatMap {NetworkService.shared.updateMeta(params: ["cover_url": $0])}
                // Catch error and reverse image
                .subscribe(onError: {[weak self] error in
                    self?.coverImageView.image = originalImage
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self?.showError(error)
                    }
                })
                .disposed(by: DisposeBag())
        }
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    func onUpdateAvatar(delete: Bool = false) {
        // Save image for reversing when update failed
        let originalImage = self.avatarView.image
        let originGif = self.avatarView.gifImage
        
        // On deleting
        if delete {
            self.avatarView.setNonAvatarImageWithId(UserDefaults.standard.string(forKey: Config.currentUserNameKey) ?? UserDefaults.standard.string(forKey: Config.currentUserIDKey) ?? "XXX")
            
            NetworkService.shared.updateMeta(params: ["avatar_url": ""])
                .subscribe(onError: {[weak self] error in
                    if let gif = originGif {
                        self?.avatarView.setGifImage(gif)
                    } else {
                        self?.avatarView.image = originalImage
                    }
                    
                    self?.showError(error)
                })
                .disposed(by: DisposeBag())
            return
        }
        
        // On updating
        let chooseAvatarVC = controllerContainer.resolve(ProfileChooseAvatarVC.self)!
        self.present(chooseAvatarVC, animated: true, completion: nil)
        
        return chooseAvatarVC.viewModel.didSelectImage
            .filter {$0 != nil}
            .map {$0!}
            // Upload image
            .flatMap { image -> Single<String> in
                self.avatarView.image = image
                return NetworkService.shared.uploadImage(image)
            }
            // Save to db
            .flatMap {NetworkService.shared.updateMeta(params: ["avatar_url": $0])}
            // Catch error and reverse image
            .subscribe(onError: {[weak self] error in
                self?.avatarView.image = originalImage
                self?.showError(error)
            })
            .disposed(by: DisposeBag())
    }
}
