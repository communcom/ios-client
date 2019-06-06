//
//  EditorPageVC+Actions.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 03/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxSwift
import MBProgressHUD
import TLPhotoPicker

extension EditorPageVC {
    
    @IBAction func cameraButtonTap() {
        // If updating
        let pickerVC = CustomTLPhotosPickerVC.singleImage
        self.present(pickerVC, animated: true, completion: nil)
        
        // Save original image to reverse
        let originalImage = self.imageView.image
        
        pickerVC.rx.didSelectAssets
            .filter {($0.count > 0) && ($0.first?.fullResolutionImage != nil)}
            .map {$0.first!.fullResolutionImage!}
            .do(onNext: {image in
                self.imageView.image = image
                self.imageView.showLoading()
                self.sendPostButton.isEnabled = false
                pickerVC.dismiss(animated: true, completion: nil)
            })
            .flatMap {image in
                return NetworkService.shared.uploadImage(image)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (url) in
                self.imageView.hideLoading()
                self.viewModel?.addImage(with: url)
                self.sendPostButton.isEnabled = true
            }, onError: { (error) in
                self.showGeneralError()
                self.imageView.hideLoading()
                self.imageView.image = originalImage
                self.sendPostButton.isEnabled = true
            })
            .disposed(by: disposeBag)
            // Upload image
            
    }
    
    @IBAction func closeButtonDidTouch(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeImageButton(_ sender: Any) {
        imageView.image = nil
        viewModel?.addImage(with: nil)
    }
    
}
