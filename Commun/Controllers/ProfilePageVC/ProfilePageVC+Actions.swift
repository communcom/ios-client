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

extension ProfilePageVC {
    func onUpdateCover() -> CocoaAction {
        return CocoaAction {_ in
            let pickerVC = CustomTLPhotosPickerVC()
            var configure = TLPhotosPickerConfigure()
            configure.singleSelectedMode = true
            configure.allowedLivePhotos = false
            configure.allowedVideo = false
            configure.allowedVideoRecording = false
            configure.mediaType = .image
            pickerVC.configure = configure
            self.present(pickerVC, animated: true, completion: nil)
            
            return pickerVC.rx.didSelectAssets
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
                .do(onNext: {image in
                    if image != nil {
                        self.viewModel.coverImage.accept(image)
                    }
                    #warning("Send image change request to server")
                })
                .take(1)
                .ignoreElements()
                .asObservable()
                .map {_ in}
        }
    }
    
    func onUpdateAvatar() -> CocoaAction {
        return CocoaAction {_ in
            let chooseAvatarVC = controllerContainer.resolve(ProfileChooseAvatarVC.self)!
            self.present(chooseAvatarVC, animated: true, completion: {
                chooseAvatarVC.viewModel.avatar.accept(self.userAvatarImage.image)
            })
            return .just(())
        }
    }
}
