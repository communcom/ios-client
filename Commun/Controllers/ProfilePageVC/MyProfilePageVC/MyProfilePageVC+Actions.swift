//
//  MyProfilePageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
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
    
    @objc override func moreActionsButtonDidTouch(_ sender: Any) {
        let headerView = UIView(height: 40)
        
        let avatarImageView = MyAvatarImageView(size: 40)
        avatarImageView.observeCurrentUserAvatar()
            .disposed(by: disposeBag)
        headerView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        let userNameLabel = UILabel.with(text: viewModel.profile.value?.username, textSize: 15, weight: .semibold)
        headerView.addSubview(userNameLabel)
        userNameLabel.autoPinEdge(toSuperviewEdge: .top)
        userNameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userNameLabel.autoPinEdge(toSuperviewEdge: .trailing)

        let userIdLabel = UILabel.with(text: "@\(viewModel.profile.value?.userId ?? "")", textSize: 12, textColor: .appMainColor)
        headerView.addSubview(userIdLabel)
        userIdLabel.autoPinEdge(.top, to: .bottom, of: userNameLabel, withOffset: 3)
        userIdLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userIdLabel.autoPinEdge(toSuperviewEdge: .trailing)
        
        showCommunActionSheet(style: .profile, headerView: headerView, actions: [
            CommunActionSheet.Action(title: "saved".localized().uppercaseFirst, icon: UIImage(named: "profile_options_saved"), handle: {
                #warning("change filter")
                let vc = PostsViewController()
                vc.title = "saved posts".localized().uppercaseFirst
                self.show(vc, sender: self)
            }),
            CommunActionSheet.Action(title: "liked".localized().uppercaseFirst, icon: UIImage(named: "profile_options_liked"), handle: {
                #warning("change filter")
                let vc = PostsViewController()
                vc.title = "liked posts".localized().uppercaseFirst
                self.show(vc, sender: self)
            }),
            CommunActionSheet.Action(title: "blacklist".localized().uppercaseFirst, icon: UIImage(named: "profile_options_blacklist"), handle: {
                self.show(MyProfileBlacklistVC(), sender: self)
            }),
            CommunActionSheet.Action(title: "settings".localized().uppercaseFirst, icon: UIImage(named: "profile_options_settings"), handle: {
                self.show(MyProfileSettingsVC(), sender: self)
            }, marginTop: 14)
        ]) {
            
        }
    }
    
    @objc func settingsButtonDidTouch(_ sender: Any) {
        let settingsVC = controllerContainer.resolve(SettingsVC.self)!
        self.show(settingsVC, sender: nil)
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
        let originalImage = coverImageView.image
        let originGif = headerView.avatarImageView.gifImage
        
        // If deleting
        if delete {
            coverImageView.image = .placeholder
            NetworkService.shared.updateMeta(params: ["cover_image": ""])
                .subscribe(onError: {[weak self] error in
                    if let gif = originGif {
                        self?.coverImageView.setGifImage(gif)
                    }
                    else {
                        self?.coverImageView.image = originalImage
                    }
                    
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
        let originGif = headerView.avatarImageView.gifImage
        
        // On deleting
        if delete {
            headerView.avatarImageView.setNonAvatarImageWithId(self.viewModel.profile.value!.username ?? self.viewModel.profile.value!.userId)
            NetworkService.shared.updateMeta(params: ["profile_image": ""])
                .subscribe(onError: {[weak self] error in
                    if let gif = originGif {
                        self?.headerView.avatarImageView.setGifImage(gif)
                    }
                    else {
                        self?.headerView.avatarImageView.image = originalImage
                    }
                    
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
    @objc func addBioButtonDidTouch(_ sender: Any) {
        self.onUpdateBio(new: true)
    }
    
    @objc func bioLabelDidTouch(_ sender: Any) {
        showCommunActionSheet(
            title: String(format: "%@ %@", "change".localized().uppercaseFirst, "profile description".localized()),
            actions: [
                CommunActionSheet.Action(
                    title: "edit".localized().uppercaseFirst,
                    icon: UIImage(named: "edit"),
                    handle: {[unowned self] in
                        self.onUpdateBio()
                }),
                CommunActionSheet.Action(
                    title: "delete".localized().uppercaseFirst,
                    icon: UIImage(named: "delete"),
                    handle: {[unowned self] in
                        self.onUpdateBio(delete: true)
                    },
                    tintColor: .red
                )
        ])
    }
    
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
        
        let editBioVC = MyProfileEditBioVC()
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
