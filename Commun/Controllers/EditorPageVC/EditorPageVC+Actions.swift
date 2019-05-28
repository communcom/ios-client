//
//  EditorPageVC+Actions.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 03/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension EditorPageVC {
    
    @IBAction func cameraButtonTap() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func adultButtonTap() {
        viewModel?.setAdult()
    }
    
    @IBAction func postButtonTap() {
        viewModel?.sendPost()
            .subscribe(onCompleted: {
                self.dismiss(animated: true, completion: nil)
            }, onError: { _ in
                self.showGeneralError()
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func closeButtonDidTouch(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
