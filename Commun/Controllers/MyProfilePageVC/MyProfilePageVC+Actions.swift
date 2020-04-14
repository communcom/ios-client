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
        showCommunActionSheet(
            title: String(format: "%@ %@", "change".localized().uppercaseFirst, (cover ? "cover photo" : "profile photo").localized()),
            titleFont: .systemFont(ofSize: 15, weight: .semibold),
            titleAlignment: .left,
            actions: [
                CommunActionSheet.Action(
                    title: "choose from gallery".localized().uppercaseFirst,
                    icon: UIImage(named: "photo_solid"),
                    handle: {[unowned self] in
                        cover ? self.onUpdateCover() : self.onUpdateAvatar()
                }),
                CommunActionSheet.Action(title: String(format: "%@ %@", "delete current".localized().uppercaseFirst, (cover ? "cover photo" : "profile photo").localized()),
                                         icon: UIImage(named: "delete"),
                                         tintColor: .red,
                                         handle: {[unowned self] in
                                            cover ? self.onUpdateCover(delete: true) : self.onUpdateAvatar(delete: true)
                    }
                )
        ])
    }
    
    func onUpdateCover(delete: Bool = false) {
        // Save originalImage for reverse when update failed
        let originalImage = coverImageView.image
        let originGif = headerView.avatarImageView.gifImage
        
        // If deleting
        if delete {
            coverImageView.image = .placeholder
            NetworkService.shared.updateMeta(params: ["cover_url": ""])
                .subscribe(onError: {[weak self] error in
                    if let gif = originGif {
                        self?.coverImageView.setGifImage(gif)
                    } else {
                        self?.coverImageView.image = originalImage
                    }
                    
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
                self.coverImageView.showLoading(cover: false, spinnerColor: .white)
                
                guard let image = image else {return}
                NetworkService.shared.uploadImage(image)
                    .flatMap { url -> Single<String> in
                        return NetworkService.shared.updateMeta(params: ["cover_url": url]).andThen(Single<String>.just(url))
                    }
                    .subscribe(onSuccess: { [weak self] (_) in
                        self?.coverImageView.hideLoading()
                    }, onError: { [weak self] (error) in
                        self?.coverImageView.hideLoading()
                        self?.coverImageView.image = originalImage
                        self?.showError(error)
                    })
                    .disposed(by: self.disposeBag)
            }
            
            let nc = BaseNavigationController(rootViewController: coverEditVC)
            pickerVC.present(nc, animated: true, completion: nil)
        }
        
        pickerVC.modalPresentationStyle = .fullScreen
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    func onUpdateAvatar(delete: Bool = false) {
        // Save image for reversing when update failed
        let originalImage = headerView.avatarImageView.image
        let originGif = headerView.avatarImageView.gifImage
        
        // On deleting
        if delete {
            headerView.avatarImageView.image = UIImage(named: "empty-avatar")
            NetworkService.shared.updateMeta(params: ["avatar_url": ""])
                .subscribe(onError: {[weak self] error in
                    if let gif = originGif {
                        self?.headerView.avatarImageView.setGifImage(gif)
                    } else {
                        self?.headerView.avatarImageView.image = originalImage
                    }
                    
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
                self.headerView.avatarImageView.showLoading(cover: false, spinnerColor: .white)
                self.headerView.avatarImageView.image = image
                return NetworkService.shared.uploadImage(image)
            }
            // Save to db
            .flatMap {NetworkService.shared.updateMeta(params: ["avatar_url": $0]).andThen(Single<String>.just($0))}
            // Catch error and reverse image
            .subscribe(onNext: { [weak self] (_) in
                self?.headerView.avatarImageView.hideLoading()
            }, onError: { [weak self] (error) in
                self?.headerView.avatarImageView.hideLoading()
                self?.coverImageView.image = originalImage
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Biography
    @objc func addBioButtonDidTouch(_ sender: Any) {
        self.onUpdateBio(new: true)
    }
    
    @objc func bioLabelDidTouch(_ sender: Any) {
        showCommunActionSheet(
            title: String(format: "%@ %@", "change".localized().uppercaseFirst, "profile description".localized()),
            actions: [
                CommunActionSheet.Action(title: "edit".localized().uppercaseFirst,
                                         icon: UIImage(named: "edit"),
                                         handle: {[unowned self] in
                                            self.onUpdateBio()
                }),
                CommunActionSheet.Action(title: "delete".localized().uppercaseFirst,
                                         icon: UIImage(named: "delete"),
                                         tintColor: .red,
                                         handle: {[unowned self] in
                                            self.onUpdateBio(delete: true)
                    }
                )
        ])
    }
    
    func onUpdateBio(new: Bool = false, delete: Bool = false) {
        // Save original bio for reversing
        let originalBio = headerView.descriptionLabel.text
        
        // On deleting
        if delete {
            headerView.descriptionLabel.text = nil
            NetworkService.shared.updateMeta(params: ["biography": ""])
                .subscribe(onError: {[weak self] error in
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
            .flatMap {bio -> Completable in
                self.headerView.descriptionLabel.text = bio
                return NetworkService.shared.updateMeta(params: ["biography": bio])
            }
            .subscribe(onError: {[weak self] error in
                self?.headerView.descriptionLabel.text = originalBio
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
}
