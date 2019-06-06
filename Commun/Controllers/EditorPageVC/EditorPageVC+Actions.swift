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

extension EditorPageVC {
    
    @IBAction func cameraButtonTap() {
        // If updating
        let pickerVC = CustomTLPhotosPickerVC.singleImage
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    @IBAction func closeButtonDidTouch(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
