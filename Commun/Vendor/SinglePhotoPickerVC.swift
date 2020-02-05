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
import MBProgressHUD

class SinglePhotoPickerVC: TLPhotosPickerViewController {
    // MARK: - Properties
    var completion: ((UIImage) -> Void)?
    var hud: MBProgressHUD?

    // MARK: - Initializers
    override init() {
        super.init()
        var configure = TLPhotosPickerConfigure()
        configure.singleSelectedMode = true
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
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .annularDeterminate
        hud.label.text = "download image from iCloud".localized().uppercaseFirst + "..."
        hud.backgroundColor = UIColor(white: 0, alpha: 0.2)
        hud.isUserInteractionEnabled = true
        self.hud = hud

        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = false
        option.isNetworkAccessAllowed = true
        option.progressHandler = { [weak self] progress, error, _, _ in
            DispatchQueue.main.async {
                hud.progress = Float(progress)
                if let error = error {
                    hud.hide(animated: true)
                    self?.showError(error)
                }
            }
        }
        
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option) { [weak self] (image, _) in
            self?.hud?.hide(animated: true)
            guard let image = image else {return}
            self?.completion?(image)
        }
    }
    
    override func cancelButtonTap() {
        hud?.hide(animated: true)
        self.dismiss(animated: true, completion: nil)
    }


}
