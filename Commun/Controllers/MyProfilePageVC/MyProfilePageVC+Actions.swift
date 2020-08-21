//
//  MyProfilePageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyGif

extension MyProfilePageVC {
    @objc func changeCoverBtnDidTouch(_ sender: Any) {
        openActionSheet(cover: true)
    }
    
    @objc func changeAvatarBtnDidTouch(_ sender: Any) {
        openActionSheet(cover: false)
    }
    
    @objc func walletDidTouch() {
        let state = (viewModel as! MyProfilePageViewModel).balancesVM.state.value
       
        switch state {
        case .error:
            (viewModel as! MyProfilePageViewModel).balancesVM.reload()
      
        case .listEnded, .loading(false):
            let walletVC = CommunWalletVC()
            show(walletVC, sender: nil)
        default:
            break
        }
    }
    
    // MARK: - Covers + Avatar
    func openActionSheet(cover: Bool) {
        showCMActionSheet(
            title: "change \(cover ? "cover photo": "avatar")".localized().uppercaseFirst,
            actions: [
                .default(
                    title: "choose from gallery".localized().uppercaseFirst,
                    iconName: "photo_solid",
                    handle: {[unowned self] in
                        cover ? self.onUpdateCover() : self.onUpdateAvatar()
                }),
                .default(
                    title: "remove current \(cover ? "cover photo" : "avatar")".localized().uppercaseFirst,
                    iconName: "delete",
                    tintColor: .appRedColor,
                    handle: {[unowned self] in
                        cover ? self.onUpdateCover(delete: true) : self.onUpdateAvatar(delete: true)
                    }
                )
        ])
    }
    
    func onUpdateCover(delete: Bool = false) {
        // Save originalImage for reverse when update failed
        let originImageUrl = ResponseAPIContentGetProfile.current?.coverUrl
        
        // If deleting
        if delete {
            coverImageView.image = .placeholder
            ResponseAPIContentGetProfile.updateCurrentUserProfile(coverUrl: "")
            BlockchainManager.instance.updateProfile(params: ["cover_url": ""])
                .subscribe(onError: {[weak self] (error) in
                    ResponseAPIContentGetProfile.updateCurrentUserProfile(coverUrl: originImageUrl)
                    self?.showError(error)
                })
                .disposed(by: disposeBag)
            return
        }
        
        // If updating
        let pickerVC = SinglePhotoPickerVC()
       
        pickerVC.completion = { image in
            let coverEditVC = MyProfileEditCoverVC()
            coverEditVC.modalPresentationStyle = .fullScreen
            coverEditVC.joinedDateString = self.viewModel.profile.value?.registration?.time
            coverEditVC.updateWithImage(image)
            coverEditVC.completion = {image in
                coverEditVC.dismiss(animated: true, completion: {
                    pickerVC.dismiss(animated: true, completion: nil)
                })
                self.coverImageView.image = image
                self.coverImageView.showLoading(cover: false, spinnerColor: .appWhiteColor)
                
                guard let image = image else {return}
                RestAPIManager.instance.uploadImage(image)
                    .flatMap { url -> Single<String> in
                        BlockchainManager.instance.updateProfile(params: ["cover_url": url]).andThen(.just(url))
                    }
                    .subscribe(onSuccess: { [weak self] (url) in
                        self?.coverImageView.hideLoading()
                        ResponseAPIContentGetProfile.updateCurrentUserProfile(coverUrl: url)
                    }, onError: { [weak self] (error) in
                        self?.coverImageView.hideLoading()
                        ResponseAPIContentGetProfile.updateCurrentUserProfile(coverUrl: originImageUrl)
                        self?.showError(error)
                    })
                    .disposed(by: self.disposeBag)
            }
            
            let nc = SwipeNavigationController(rootViewController: coverEditVC)
            pickerVC.present(nc, animated: true, completion: nil)
        }
        
        pickerVC.modalPresentationStyle = .fullScreen
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    func onUpdateAvatar(delete: Bool = false) {
        // Save image for reversing when update failed
        let originImageUrl = ResponseAPIContentGetProfile.current?.avatarUrl
        
        // On deleting
        if delete {
            headerView.avatarImageView.image = UIImage(named: "empty-avatar")
            ResponseAPIContentGetProfile.updateCurrentUserProfile(avatarUrl: "")
            BlockchainManager.instance.updateProfile(params: ["avatar_url": ""])
                .subscribe(onError: {[weak self] error in
                    ResponseAPIContentGetProfile.updateCurrentUserProfile(avatarUrl: originImageUrl)
                    self?.showError(error)
                })
                .disposed(by: disposeBag)
            return
        }
        
        // On updating
        let chooseAvatarVC = ProfileChooseAvatarVC.fromStoryboard("ProfileChooseAvatarVC", withIdentifier: "ProfileChooseAvatarVC")
        self.present(chooseAvatarVC, animated: true, completion: nil)
        
        return chooseAvatarVC.viewModel.didSelectImage
            .filter {$0 != nil}
            .map {$0!}
            // Upload image
            .flatMap { image -> Single<String> in
                self.headerView.avatarImageView.showLoading(cover: false, spinnerColor: .appWhiteColor)
                self.headerView.avatarImageView.image = image
                return RestAPIManager.instance.uploadImage(image)
            }
            // Save to db
            .flatMap {BlockchainManager.instance.updateProfile(params: ["avatar_url": $0]).andThen(Single<String>.just($0))}
            // Catch error and reverse image
            .subscribe(onNext: { [weak self] (url) in
                self?.headerView.avatarImageView.hideLoading()
                ResponseAPIContentGetProfile.updateCurrentUserProfile(avatarUrl: url)
            }, onError: { [weak self] (error) in
                self?.headerView.avatarImageView.hideLoading()
                ResponseAPIContentGetProfile.updateCurrentUserProfile(avatarUrl: originImageUrl)
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Biography
    @objc func addBioButtonDidTouch(_ sender: Any) {
        self.onUpdateBio(new: true)
    }
    
    @objc func bioLabelDidTouch(_ sender: Any) {
        showCMActionSheet(
            title: "\("change".localized().uppercaseFirst) \("profile description".localized())",
            actions: [
                .default(
                    title: "edit".localized().uppercaseFirst,
                    iconName: "edit",
                    handle: {
                        self.onUpdateBio()
                    }
                ),
                .default(
                    title: "delete".localized().uppercaseFirst,
                    iconName: "delete",
                    tintColor: .appRedColor,
                    handle: {
                        self.onUpdateBio(delete: true)
                    }
                )
            ]
        )
    }
    
    func onUpdateBio(new: Bool = false, delete: Bool = false) {
        // Save original bio for reversing
        let originalBio = headerView.descriptionLabel.text
        
        // On deleting
        if delete {
            headerView.descriptionLabel.text = nil
            BlockchainManager.instance.updateProfile(params: ["biography": ""])
                .subscribe(onCompleted: {
                    ResponseAPIContentGetProfile.updateCurrentUserProfile(bio: "")
                }, onError: {[weak self] error in
                    self?.showError(error)
                    self?.headerView.descriptionLabel.text = originalBio
                })
                .disposed(by: disposeBag)
            return
        }
        
        let editBioVC = MyProfileEditBioVC()
       
        if !new {
            editBioVC.bio = headerView.descriptionLabel.text
        }
       
        self.present(editBioVC, animated: true, completion: nil)
        
        editBioVC.didConfirm
            .flatMap {bio -> Single<String> in
                self.headerView.descriptionLabel.text = bio
                return BlockchainManager.instance.updateProfile(params: ["biography": bio])
                    .andThen(.just(bio))
            }
            .subscribe(onNext: { (bio) in
                ResponseAPIContentGetProfile.updateCurrentUserProfile(bio: bio)
            }, onError: {[weak self] (error) in
                self?.headerView.descriptionLabel.text = originalBio
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
}
