//
//  ProfileChooseAvatarViewModel.swift
//  Commun
//
//  Created by Chung Tran on 24/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa
import Photos
import PhotosUI
import Action
import RxSwift

struct ProfileChooseAvatarViewModel {
    var avatar = BehaviorRelay<UIImage?>(value: nil)
    var authorizationStatus = BehaviorRelay<PHAuthorizationStatus>(value: PHPhotoLibrary.authorizationStatus())
    
    func onRequestPermission() -> CocoaAction {
        return CocoaAction {
            return Observable<Void>.create { observer in
                switch self.authorizationStatus.value {
                case .denied, .restricted:
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    observer.onCompleted()
                    break
                case .authorized:
                    observer.onCompleted()
                    break
                default:
                    PHPhotoLibrary.requestAuthorization({ (status) in
                        DispatchQueue.main.sync {
                            self.authorizationStatus.accept(status)
                        }
                        observer.onCompleted()
                    })
                }
                
                return Disposables.create()
            }
        }
    }
}
