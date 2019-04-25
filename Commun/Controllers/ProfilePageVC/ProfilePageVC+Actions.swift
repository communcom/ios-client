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
        if delete {
            guard var params = viewModel.updatemetaParams else {return}
            params["cover_image"] = nil
            viewModel.updateSubject.onNext(params)
            return
        }
        
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
            .flatMap { assets -> Observable<UIImage?> in
                if assets.count == 0 || assets[0].type != TLPHAsset.AssetType.photo || assets[0].fullResolutionImage == nil {
                    return .just(nil)
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
                    .flatMap({ (image) -> Single<UIImage?> in
                        coverEditVC.dismiss(animated: true, completion: {
                            pickerVC.dismiss(animated: true, completion: nil)
                        })
                        return .just(image)
                    })
            }
            .subscribe(onNext: {image in
                if image != nil {
                    self.update(.cover, with: image!)
                }
            })
            .disposed(by: bag)
    }
    
    func onUpdateAvatar(delete: Bool = false) {
        if delete {
            guard var params = viewModel.updatemetaParams else {return}
            params["profile_image"] = nil
            viewModel.updateSubject.onNext(params)
            return
        }
        let chooseAvatarVC = controllerContainer.resolve(ProfileChooseAvatarVC.self)!
        self.present(chooseAvatarVC, animated: true, completion: {
            chooseAvatarVC.viewModel.avatar.accept(self.userAvatarImage.image)
        })
        
        return chooseAvatarVC.viewModel.didSelectImage
            .subscribe(onNext: {image in
                if image != nil {
                    self.update(.avatar, with: image!)
                }
            })
            .disposed(by: bag)
    }
    
    private func update(_ imageType: ImageType, with newImage: UIImage) {
        guard let imageView = (imageType == .cover) ? self.userCoverImage : self.userAvatarImage else {return}
        
        let originalImage = imageView.image
        imageView.image = newImage
        
        NetworkService.shared.uploadImage(newImage, imageType: imageType)
            .subscribe(onError: {_ in
                self.showAlert(title: "Error".localized(), message: "Something went wrong".localized())
                imageView.image = originalImage
            })
            .disposed(by: self.bag)
    }
    
    // MARK: - Biography
    func onUpdateBio(new: Bool = false, delete: Bool = false) {
        if delete {
            guard var params = viewModel.updatemetaParams else {return}
            params["about"] = nil
            viewModel.updateSubject.onNext(params)
            return
        }
        
        let editBioVC = controllerContainer.resolve(ProfileEditBioVC.self)!
        if !new {
            editBioVC.bio = self.bioLabel.text
        }
        self.present(editBioVC, animated: true, completion: nil)
        
        editBioVC.didConfirm
            .subscribe(onNext: {bio in
                self.bioLabel.text = bio
                guard var params = self.viewModel.updatemetaParams else {return}
                params["about"] = bio
                self.viewModel.updateSubject.onNext(params)
            })
            .disposed(by: bag)
    }
}
