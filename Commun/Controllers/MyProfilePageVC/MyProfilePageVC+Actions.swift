//
//  MyProfilePageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

extension MyProfilePageVC {
    @objc func changeCoverBtnDidTouch(_ sender: Any) {
        openActionSheet(cover: true)
    }
    
    @objc func changeAvatarBtnDidTouch(_ sender: Any) {
        openActionSheet(cover: false)
    }
    
    @objc func addBioButtonDidTouch(_ sender: Any) {
        self.onUpdateBio(new: true)
    }
    
    @objc func settingsButtonDidTouch(_ sender: Any) {
        let settingsVC = controllerContainer.resolve(SettingsVC.self)!
        self.show(settingsVC, sender: nil)
    }
    
    @objc func bioLableDidTouch(_ sender: Any) {
        self.showActionSheet(title:     String(format: "%@ %@", "change".localized().uppercaseFirst, "profile description".localized()),
                             actions:   [
                                UIAlertAction(title: "edit".localized().uppercaseFirst, style: .default, handler: { (_) in
                                    self.onUpdateBio()
                                }),
                                UIAlertAction(title: "delete".localized().uppercaseFirst, style: .destructive, handler: { (_) in
                                    self.onUpdateBio(delete: true)
                                }),
            ])
    }
    
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
        let originalImage = coverImageView.image
        
        // If deleting
        if delete {
            coverImageView.image = .placeholder
            NetworkService.shared.updateMeta(params: ["cover_image": ""])
                .subscribe(onError: {[weak self] error in
                    self?.coverImageView.image = originalImage
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
                self.coverImageView.image = image
                return NetworkService.shared.uploadImage(image)
            }
            // Save to db
            .flatMap {NetworkService.shared.updateMeta(params: ["cover_image": $0])}
            // Catch error and reverse image
            .subscribe(onError: {[weak self] error in
                self?.coverImageView.image = originalImage
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self?.showError(error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func onUpdateAvatar(delete: Bool = false) {
        // Save image for reversing when update failed
        let originalImage = headerView.avatarImageView.image
        
        // On deleting
        if delete {
            headerView.avatarImageView.setNonAvatarImageWithId(self.viewModel.profile.value!.username ?? self.viewModel.profile.value!.userId)
            NetworkService.shared.updateMeta(params: ["profile_image": ""])
                .subscribe(onError: {[weak self] error in
                    self?.headerView.avatarImageView.image = originalImage
                    self?.showError(error)
                })
                .disposed(by: disposeBag)
            return
        }
        
        // On updating
        let chooseAvatarVC = controllerContainer.resolve(ProfileChooseAvatarVC.self)!
        self.present(chooseAvatarVC, animated: true, completion: {
            chooseAvatarVC.viewModel.avatar.accept(self.headerView.avatarImageView.image)
        })
        
        return chooseAvatarVC.viewModel.didSelectImage
            .filter {$0 != nil}
            .map {$0!}
            // Upload image
            .flatMap { image -> Single<String> in
                self.headerView.avatarImageView.image = image
                return NetworkService.shared.uploadImage(image)
            }
            // Save to db
            .flatMap {NetworkService.shared.updateMeta(params: ["profile_image": $0])}
            // Catch error and reverse image
            .subscribe(onError: {[weak self] error in
                self?.headerView.avatarImageView.image = originalImage
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Biography
    func onUpdateBio(new: Bool = false, delete: Bool = false) {
        // Save original bio for reversing
        let originalBio = headerView.descriptionLabel.text
        
        // On deleting
        if delete {
            headerView.descriptionLabel.text = nil
            NetworkService.shared.updateMeta(params: ["about": ""])
                .subscribe(onError: {[weak self] error in
                    self?.showError(error)
                    self?.headerView.descriptionLabel.text = originalBio
                })
                .disposed(by: disposeBag)
            return
        }
        
        let editBioVC = controllerContainer.resolve(ProfileEditBioVC.self)!
        if !new {
            editBioVC.bio = headerView.descriptionLabel.text
        }
        self.present(editBioVC, animated: true, completion: nil)
        
        editBioVC.didConfirm
            .flatMap {bio -> Completable in
                self.headerView.descriptionLabel.text = bio
                return NetworkService.shared.updateMeta(params: ["about": bio])
            }
            .subscribe(onError: {[weak self] error in
                self?.headerView.descriptionLabel.text = originalBio
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
}
