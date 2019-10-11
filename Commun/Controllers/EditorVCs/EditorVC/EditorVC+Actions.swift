//
//  EditorVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

extension EditorVC {
    // MARK: - Immutable actions
    @objc func close() {
        guard viewModel.postForEdit == nil,
            !contentTextView.text.isEmpty else
        {
            dismiss(animated: true, completion: nil)
            return
        }
        
        showAlert(
            title: "save post as draft".localized().uppercaseFirst + "?",
            message: "draft let you save your edits, so you can come back later".localized().uppercaseFirst,
            buttonTitles: ["save".localized().uppercaseFirst, "delete".localized().uppercaseFirst],
            highlightedButtonIndex: 0) { (index) in
                if index == 0 {
                    self.saveDraft {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
                else if index == 1 {
                    // remove draft if exists
                    self.removeDraft()
                    
                    // close
                    self.dismiss(animated: true, completion: nil)
                }
        }
    }
    
    func retrieveDraft() {
        showAlert(
            title: "retrieve draft".localized().uppercaseFirst,
            message: "you have a draft version on your device".localized().uppercaseFirst + ". " + "continue editing it".localized().uppercaseFirst + "?",
            buttonTitles: ["OK".localized(), "cancel".localized().uppercaseFirst],
            highlightedButtonIndex: 0) { (index) in
                if index == 0 {
                    self.getDraft()
                }
                else if index == 1 {
                    self.removeDraft()
                }
        }
    }
    
    // MARK: - Add image
    func addImage() {
        view.endEditing(true)
        
        chooseFromGallery()
//        showActionSheet(title:     "add image".localized().uppercaseFirst,
//                             actions:   [
//                                UIAlertAction(title:    "choose from gallery".localized().uppercaseFirst,
//                                              style:    .default,
//                                              handler:  { _ in
//                                                self.chooseFromGallery()
//                                }),
//                                UIAlertAction(title:   "insert image from URL".localized().uppercaseFirst,
//                                              style:    .default,
//                                              handler:  { _ in
//                                                self.selectImageFromUrl()
//                                })])
    }
    
    func chooseFromGallery() {
        let pickerVC = CustomTLPhotosPickerVC.singleImage
        self.present(pickerVC, animated: true, completion: nil)
        
        pickerVC.rx.didSelectAssets
            .filter {($0.count > 0) && ($0.first?.fullResolutionImage != nil)}
            .map {$0.first!.fullResolutionImage!}
            .subscribe(onNext: {[weak self] image in
                guard let strongSelf = self else {return}
                let alert = UIAlertController(
                    title:          "description".localized().uppercaseFirst,
                    message:        "add a description for your image".localized().uppercaseFirst,
                    preferredStyle: .alert)
                
                alert.addTextField { field in
                    field.placeholder = "description".localized().uppercaseFirst + "(" + "optional".localized() + ")"
                }
                
                alert.addAction(UIAlertAction(title: "add".localized().uppercaseFirst, style: .cancel, handler: { _ in
                    strongSelf.didChooseImageFromGallery(image, description: alert.textFields?.first?.text)
                    pickerVC.dismiss(animated: true, completion: nil)
                }))
                
                pickerVC.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
//    func selectImageFromUrl() {
//        let alert = UIAlertController(
//            title:          "select image".localized().uppercaseFirst,
//            message:        "select image from an URL".localized().uppercaseFirst,
//            preferredStyle: .alert)
//        
//        alert.addTextField { field in
//            field.placeholder = "image URL".localized().uppercaseFirst
//        }
//        
//        alert.addTextField { field in
//            field.placeholder = "description".localized().uppercaseFirst + "(" + "optional".localized() + ")"
//        }
//        
//        alert.addAction(UIAlertAction(title: "add".localized().uppercaseFirst, style: .cancel, handler: {[weak self] _ in
//            guard let urlString = alert.textFields?.first?.text else { return }
//            self?.didAddImageFromURLString(urlString, description: alert.textFields?.last?.text)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "cancel".localized().uppercaseFirst, style: .default, handler: nil))
//        
//        present(alert, animated: true, completion: nil)
//    }
    
    // MARK: - Add link
    func addLink() {
        var currentSelectedRange = contentTextView.selectedRange
        if let urlString = contentTextView.currentTextStyle.value.urlString
        {
            // Remove link that is not a mention or tag
            if urlString.isLink {
                showActionSheet(title: urlString, message: nil, actions: [
                    UIAlertAction(title: "remove".localized().uppercaseFirst, style: .destructive, handler: { (_) in
                        self.contentTextView.removeLink()
                    })
                ])
            }
            
        }
        else {
            // Add link
            let alert = UIAlertController(
                title:          "add link".localized().uppercaseFirst,
                message:        "select a link to add to text".localized().uppercaseFirst,
                preferredStyle: .alert)
            
            alert.addTextField { field in
                field.placeholder = "URL".localized()
            }
            
            alert.addTextField { field in
                field.placeholder = "placeholder".localized().uppercaseFirst + "(" + "optional".localized() + ")"
                let string = self.contentTextView.selectedAString.string
                if !string.isEmpty {
                    field.text = string
                }
            }
            
            alert.addAction(UIAlertAction(title: "add".localized().uppercaseFirst, style: .cancel, handler: {[weak self] _ in
                guard let urlString = alert.textFields?.first?.text
                else {
                    self?.showErrorWithMessage("URL".localized() + " " + "is missing".localized())
                    return
                }
                self?.contentTextView.selectedRange = currentSelectedRange
                self?.didAddLink(urlString, placeholder: alert.textFields?.last?.text)
            }))
            
            alert.addAction(UIAlertAction(title: "cancel".localized().uppercaseFirst, style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Add color
    func pickColor(sender: UIView) {
        let vc = ColorPickerViewController()
        vc.modalPresentationStyle = .popover
        
        /* 3 */
        if let popoverPresentationController = vc.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .any
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.frame
            popoverPresentationController.delegate = self
            present(vc, animated: true, completion: nil)
            
            vc.didSelectColor = {color in
                self.contentTextView.setColor(color)
            }
        }
    }
    
    // MARK: - Send post
    @objc func sendPost() {
       self.view.endEditing(true)
       
       // remove draft
       removeDraft()
       
       getContentBlock()
           .observeOn(MainScheduler.instance)
           .do(onSubscribe: {
               self.showIndetermineHudWithMessage(
                       "uploading".localized().uppercaseFirst)
           })
           .flatMap { block in
                //clean
                var block = block
                block.maxId = nil
               return self.viewModel.sendPost(title: self.postTitle ?? " ", block: block)
           }
           .do(onSubscribe: {
               self.showIndetermineHudWithMessage(
                       "sending post".localized().uppercaseFirst)
           })
           .flatMap {
               self.viewModel.waitForTransaction($0)
           }
           .do(onSubscribe: {
               self.showIndetermineHudWithMessage(
                       "wait for transaction".localized().uppercaseFirst)
           })
           .subscribe(onSuccess: { (userId, permlink) in
               self.hideHud()
               // if editing post
               if (self.viewModel.postForEdit) != nil {
                   self.dismiss(animated: true, completion: nil)
               }
               // if creating post
               else {
                   // show post page
                   let postPageVC = controllerContainer.resolve(PostPageVC.self)!
                   postPageVC.viewModel.permlink = permlink
                   postPageVC.viewModel.userId = userId
                   
                   self.dismiss(animated: true) {
                       UIApplication.topViewController()?.show(postPageVC, sender: nil)
                   }
               }
           }) { (error) in
               self.hideHud()
               if let error = error as? ErrorAPI {
                   switch error {
                   case .responseUnsuccessful(message: "post not found".localized().uppercaseFirst):
                       self.dismiss(animated: true, completion: nil)
                       break
                   case .blockchain(message: let message):
                       self.showAlert(title: "error".localized().uppercaseFirst, message: message)
                       break
                   default:
                       break
                   }
               }
               self.showError(error)
           }
           .disposed(by: disposeBag)
       }
}

extension EditorVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
