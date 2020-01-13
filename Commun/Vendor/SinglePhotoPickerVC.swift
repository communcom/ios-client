//
//  SinglePhotoPickerVC.swift
//  Commun
//
//  Created by Chung Tran on 1/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import TLPhotoPicker
import Photos

class SinglePhotoPickerVC: TLPhotosPickerViewController {
    // MARK: - Properties
    var completion: ((UIImage)->Void)?
    
    // MARK: - Initializers
    override init() {
        super.init()
        var configure = TLPhotosPickerConfigure()
        configure.singleSelectedMode = true
        configure.allowedLivePhotos = false
        configure.allowedVideo = false
        configure.allowedVideoRecording = false
        configure.mediaType = .image
        self.configure = configure

        handleNoAlbumPermissions = { controller in
            DispatchQueue.main.async {
                let emptyView = PhotoLibraryAccessDeniedView()
                controller.view.addSubview(emptyView)
                emptyView.autoPinEdge(toSuperviewEdge: .leading)
                emptyView.autoPinEdge(toSuperviewEdge: .trailing)
                emptyView.autoAlignAxis(toSuperviewAxis: .horizontal)
                controller.indicator.isHidden = true
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func doneButtonTap() {
        guard let asset = selectedAssets.first?.phAsset else {return}
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = false
        option.isNetworkAccessAllowed = true

        showIndetermineHudWithMessage("download image from iCloud".localized().uppercaseFirst + "...")
        
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option) { [weak self] (image, info) in
            guard let image = image else {return}
            self?.completion?(image)
        }
    }
    
    override func cancelButtonTap() {
        self.dismiss(animated: true, completion: nil)
    }
}
