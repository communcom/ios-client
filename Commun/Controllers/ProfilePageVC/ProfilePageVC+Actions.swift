//
//  ProfilePageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 24/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import TLPhotoPicker
import Action
import RxSwift
import CyberSwift

extension ProfilePageVC {
    // MARK: - Covers + Avatar
    func openActionSheet(cover: Bool) {
        self.showActionSheet(title:     String(format: "%@ %@", "change".localized().uppercaseFirst, (cover ? "cover photo" : "profile photo").localized()),
                             actions:   [
                                UIAlertAction(title:    "choose from gallery".localized().uppercaseFirst,
                                              style:    .default,
                                              handler:  { _ in
                                                cover ? self.onUpdateCover() : self.onUpdateAvatar()
                                }),
                                UIAlertAction(title:    String(format: "%@ %@", "delete current".localized().uppercaseFirst, (cover ? "cover photo" : "profile photo").localized()),
                                              style:    .destructive,
                                              handler:  { _ in
                                                cover ? self.onUpdateCover(delete: true) : self.onUpdateAvatar(delete: true)
                                })])
    }
    
    
    func onUpdateCover(delete: Bool = false) {
        // Save originalImage for reverse when update failed
        let originalImage = userCoverImage.image
        
        // If deleting
        if delete {
            self.userCoverImage.image = UIImage(named: "ProfilePageCover")
            NetworkService.shared.updateMeta(params: ["cover_image": ""])
                .subscribe(onError: {[weak self] error in
                    self?.userCoverImage.image = originalImage
                    self?.showError(error)
                })
                .disposed(by: disposeBag)
            return
        }
        
        // If updating
        let pickerVC = CustomTLPhotosPickerVC.singleImage
        self.present(pickerVC, animated: true, completion: nil)
            
        pickerVC.rx.didSelectAnImage
            .flatMap { image -> Observable<UIImage> in
                
                let coverEditVC = controllerContainer.resolve(ProfileEditCoverVC.self)!
                
                self.viewModel.profile.filter {$0 != nil}.map {$0!}
                    .bind(to: coverEditVC.profile)
                    .disposed(by: self.disposeBag)
                
                pickerVC.present(coverEditVC, animated: true
                    , completion: {
                        coverEditVC.coverImage.image = image
                })
                
                return coverEditVC.didSelectImage
                    .do(onNext: {_ in
                        coverEditVC.dismiss(animated: true, completion: {
                            pickerVC.dismiss(animated: true, completion: nil)
                        })
                    })
            }
            // Upload image
            .flatMap {image -> Single<String> in
                self.userCoverImage.image = image
                return NetworkService.shared.uploadImage(image)
            }
            // Save to db
            .flatMap {NetworkService.shared.updateMeta(params: ["cover_image": $0])}
            // Catch error and reverse image
            .subscribe(onError: {[weak self] error in
                self?.userCoverImage.image = originalImage
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self?.showError(error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func onUpdateAvatar(delete: Bool = false) {
        // Save image for reversing when update failed
        let originalImage = self.userAvatarImage.image
        
        // On deleting
        if delete {
            self.userAvatarImage.setNonAvatarImageWithId(self.viewModel.profile.value!.username ?? self.viewModel.profile.value!.userId)
            NetworkService.shared.updateMeta(params: ["profile_image": ""])
                .subscribe(onError: {[weak self] error in
                    self?.userAvatarImage.image = originalImage
                    self?.showError(error)
                })
                .disposed(by: disposeBag)
            return
        }
        
        // On updating
        let chooseAvatarVC = controllerContainer.resolve(ProfileChooseAvatarVC.self)!
        self.present(chooseAvatarVC, animated: true, completion: {
            chooseAvatarVC.viewModel.avatar.accept(self.userAvatarImage.image)
        })
        
        return chooseAvatarVC.viewModel.didSelectImage
            .filter {$0 != nil}
            .map {$0!}
            // Upload image
            .flatMap { image -> Single<String> in
                self.userAvatarImage.image = image
                return NetworkService.shared.uploadImage(image)
            }
            // Save to db
            .flatMap {NetworkService.shared.updateMeta(params: ["profile_image": $0])}
            // Catch error and reverse image
            .subscribe(onError: {[weak self] error in
                self?.userAvatarImage.image = originalImage
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Biography
    func onUpdateBio(new: Bool = false, delete: Bool = false) {
        // Save original bio for reversing
        let originalBio = self.bioLabel.text
        
        // On deleting
        if delete {
            self.bioLabel.text = nil
            NetworkService.shared.updateMeta(params: ["about": ""])
                .subscribe(onError: {[weak self] error in
                    self?.showError(error)
                    self?.bioLabel.text = originalBio
                })
                .disposed(by: disposeBag)
            return
        }
        
        let editBioVC = controllerContainer.resolve(ProfileEditBioVC.self)!
        if !new {
            editBioVC.bio = self.bioLabel.text
        }
        self.present(editBioVC, animated: true, completion: nil)
        
        editBioVC.didConfirm
            .flatMap {bio -> Completable in
                self.bioLabel.text = bio
                return NetworkService.shared.updateMeta(params: ["about": bio])
            }
            .subscribe(onError: {[weak self] error in
                self?.bioLabel.text = originalBio
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Follow, un follow
    func onFollowTrigger() {
        
    }
    
    // MARK: - Animation
    func animateFollowing(_ completion: @escaping (() -> Void)) {
        CATransaction.begin()
        
        CATransaction.setCompletionBlock(completion)
        
        let moveDownAnim = CABasicAnimation(keyPath: "transform.scale")
        moveDownAnim.byValue = 1.2
        moveDownAnim.autoreverses = true
        followButton.layer.add(moveDownAnim, forKey: "transform.scale")
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        followButton.layer.add(fadeAnim, forKey: "Fade")
        
        CATransaction.commit()
    }
}
