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
    let avatar = BehaviorRelay<UIImage?>(value: nil)
    let authorizationStatus = BehaviorRelay<PHAuthorizationStatus>(value: PHPhotoLibrary.authorizationStatus())
    let phAssets = BehaviorRelay<[PHAsset]>(value: [])
    let didSelectImage = PublishSubject<UIImage?>()
    
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
    
    func onSelected(with scrollView: UIScrollView) -> CocoaAction {
        return CocoaAction {_ in
            UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.main.scale);
            //this is the key
            let offset:CGPoint = scrollView.contentOffset;
            
            let context = UIGraphicsGetCurrentContext()!
            context.translateBy(x: -offset.x, y: -offset.y)
            
            scrollView.layer.render(in: context)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            
            self.didSelectImage.onNext(image)
            return .just(())
        }
    }
    
    func onCancel() -> CocoaAction {
        return CocoaAction {_ in
            self.didSelectImage.onNext(nil)
            return .just(())
        }
    }
    
    func fetchAllImage() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        #warning("Remove limit later")
        options.fetchLimit = 20
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: options)
        
        var assets = [PHAsset]()
        
        for i in 0..<allPhotos.count {
            assets.append(allPhotos[i])
        }
        phAssets.accept(assets)
    }
}
