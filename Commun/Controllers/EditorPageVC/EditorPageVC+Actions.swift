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
        view.endEditing(true)
        showActionSheet(title:     "add image".localized().uppercaseFirst,
                             actions:   [
                                UIAlertAction(title:    "choose from gallery".localized().uppercaseFirst,
                                              style:    .default,
                                              handler:  { _ in
                                                self.chooseFromGallery()
                                }),
                                UIAlertAction(title:   "insert image from URL".localized().uppercaseFirst,
                                              style:    .default,
                                              handler:  { _ in
                                                self.selectImageFromUrl()
                                })])
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
                    strongSelf.contentTextView.addImage(image, description: alert.textFields?.first?.text)
                    pickerVC.dismiss(animated: true, completion: nil)
                }))
                
                alert.addAction(UIAlertAction(title: "cancel".localized().uppercaseFirst, style: .default, handler: {_ in
                    strongSelf.contentTextView.addImage(image)
                    pickerVC.dismiss(animated: true, completion: nil)
                }))
                
                pickerVC.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    func selectImageFromUrl() {
        let alert = UIAlertController(
            title:          "select image".localized().uppercaseFirst,
            message:        "select image from an URL".localized().uppercaseFirst,
            preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = "image URL".localized().uppercaseFirst
        }
        
        alert.addTextField { field in
            field.placeholder = "description".localized().uppercaseFirst + "(" + "optional".localized() + ")"
        }
        
        alert.addAction(UIAlertAction(title: "add".localized().uppercaseFirst, style: .cancel, handler: {[weak self] _ in
            guard let urlString = alert.textFields?.first?.text else { return }
            self?.contentTextView.addImage(nil, urlString: urlString, description: alert.textFields?.last?.text)
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized().uppercaseFirst, style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func sendPostButtonTap() {
        guard let viewModel = viewModel else {return}
        self.view.endEditing(true)

        contentTextView.getContentBlock()
            .observeOn(MainScheduler.instance)
            .do(onSubscribe: {
                self.navigationController?
                    .showIndetermineHudWithMessage(
                        "uploading".localized().uppercaseFirst)
            })
            .flatMap {
                viewModel.sendPost(title: self.titleTextView.text, block: $0)
            }
            .do(onSubscribe: {
                self.navigationController?
                    .showIndetermineHudWithMessage(
                        "sending post".localized().uppercaseFirst)
            })
            .flatMap {
                viewModel.waitForTransaction($0)
            }
            .do(onSubscribe: {
                self.navigationController?
                    .showIndetermineHudWithMessage(
                        "wait for transaction".localized().uppercaseFirst)
            })
            .subscribe(onSuccess: { (userId, permlink) in
                self.navigationController?.hideHud()
                // if editing post
                if (self.viewModel?.postForEdit) != nil {
                    self.dismiss(animated: true, completion: nil)
                }
                // if creating post
                else {
                    // show post page
                    let postPageVC = controllerContainer.resolve(PostPageVC.self)!
                    postPageVC.viewModel.permlink = permlink
                    postPageVC.viewModel.userId = userId
                    var viewControllers = self.navigationController!.viewControllers
                    viewControllers[0] = postPageVC
                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                }
            }) { (error) in
                self.navigationController?.hideHud()
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
    
    @IBAction func closeButtonDidTouch(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func hideKeyboardButtonDidTouch(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func richTextEditButtonDidTouch(_ sender: Any) {
        let button = sender as! UIButton
        
        if button == boldButton {
            contentTextView.setBold(from: button)
        }
        
        if button == italicButton {
            contentTextView.setItalic(from: button)
        }
    }
    
    @IBAction func colorPickerButtonDidTouch(_ sender: Any) {
        guard let sender = sender as? UIView else {return}
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
                self.colorPickerButton.backgroundColor = color
                self.contentTextView.setColor(color, sender: sender as! UIButton)
            }
        }
    }
    
    @IBAction func addLinkButtonDidTouch(_ sender: Any) {
        if let urlString = contentTextView.currentTextStyle.value.urlString {
            showActionSheet(title: urlString, message: nil, actions: [
                UIAlertAction(title: "remove".localized().uppercaseFirst, style: .destructive, handler: { (_) in
                    self.contentTextView.removeLink()
                })
            ])
        } else {
            // Add link
            let alert = UIAlertController(
                title:          "add link".localized().uppercaseFirst,
                message:        "select a link to add to text".localized().uppercaseFirst,
                preferredStyle: .alert)
            
            alert.addTextField { field in
                field.placeholder = "URL".localized()
            }
            
            alert.addTextField { field in
                field.placeholder = "placeholder".localized().uppercaseFirst
                let string = self.contentTextView.selectedAString.string
                if !string.isEmpty {
                    field.text = string
                }
            }
            
            alert.addAction(UIAlertAction(title: "add".localized().uppercaseFirst, style: .cancel, handler: {[weak self] _ in
                guard let urlString = alert.textFields?.first?.text,
                    let placeholder = alert.textFields?.last?.text
                else {
                    self?.showErrorWithMessage("URL".localized() + " " + "or".localized() + " " + "placeholder".localized() + " " + "is missing".localized())
                    return
                }
                self?.contentTextView.addLink(urlString, placeholder: placeholder)
            }))
            
            alert.addAction(UIAlertAction(title: "cancel".localized().uppercaseFirst, style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
}

extension EditorPageVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
