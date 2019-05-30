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
        self.showActionSheet(title: "Change".localized() + " " + (cover ? "Cover".localized() : "profile photo".localized()), actions: [
            UIAlertAction(title: "Choose from gallery".localized(), style: .default, handler: { _ in
                cover ? self.onUpdateCover() : self.onUpdateAvatar()
            }),
            UIAlertAction(title: "Delete current".localized() + " " + (cover ? "Cover".localized() : "profile photo".localized()), style: .destructive, handler: { _ in
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
                .subscribe(onError: {[weak self] _ in
                    self?.userCoverImage.image = originalImage
                    self?.showGeneralError()
                })
                .disposed(by: bag)
            return
        }
        
        // If updating
        let pickerVC = CustomTLPhotosPickerVC()
        var configure = TLPhotosPickerConfigure()
        configure.singleSelectedMode = true
        configure.allowedLivePhotos = false
        configure.allowedVideo = false
        configure.allowedVideoRecording = false
        configure.mediaType = .image
        pickerVC.configure = configure
        self.present(pickerVC, animated: true, completion: nil)
            
        pickerVC.rx.didSelectAssets
            .flatMap { assets -> Observable<UIImage> in
                if assets.count == 0 || assets[0].type != TLPHAsset.AssetType.photo || assets[0].fullResolutionImage == nil {
                    return .empty()
                }
                
                let image = assets[0].fullResolutionImage!
                
                let coverEditVC = controllerContainer.resolve(ProfileEditCoverVC.self)!
                
                self.viewModel.profile.filter {$0 != nil}.map {$0!}
                    .bind(to: coverEditVC.profile)
                    .disposed(by: self.bag)
                
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
                    self?.showGeneralError()
                }
            })
            .disposed(by: bag)
    }
    
    func onUpdateAvatar(delete: Bool = false) {
        // Save image for reversing when update failed
        let originalImage = self.userAvatarImage.image
        
        // On deleting
        if delete {
            self.userAvatarImage.setNonAvatarImageWithId(self.viewModel.profile.value!.username ?? self.viewModel.profile.value!.userId)
            NetworkService.shared.updateMeta(params: ["profile_image": ""])
                .subscribe(onError: {[weak self] _ in
                    self?.userAvatarImage.image = originalImage
                    self?.showGeneralError()
                })
                .disposed(by: bag)
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
                self?.showGeneralError()
            })
            .disposed(by: bag)
    }
    
    // MARK: - Biography
    func onUpdateBio(new: Bool = false, delete: Bool = false) {
        // Save original bio for reversing
        let originalBio = self.bioLabel.text
        
        // On deleting
        if delete {
            self.bioLabel.text = nil
            NetworkService.shared.updateMeta(params: ["about": ""])
                .subscribe(onError: {[weak self] _ in
                    self?.showGeneralError()
                    self?.bioLabel.text = originalBio
                })
                .disposed(by: bag)
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
                self?.showGeneralError()
            })
            .disposed(by: bag)
    }
}
