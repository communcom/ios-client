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
    
    @objc func postButtonTap() {
        viewModel?.sendPost().subscribe(onNext: { [weak self] success in
            if success {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.showAlert(title: "Error", message: "Something went wrong")
            }
        }).disposed(by: disposeBag)
    }
    
}
