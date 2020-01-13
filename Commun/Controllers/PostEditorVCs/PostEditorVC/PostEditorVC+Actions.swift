//
//  PostEditorVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift
import SafariServices
import ImageViewer_swift

extension PostEditorVC {
    // MARK: - Communities
    @objc func chooseCommunityDidTouch() {
        let vc = EditorChooseCommunityVC { (community) in
            self.viewModel.community.accept(community)
        }

        let navigation = BaseNavigationController(rootViewController: vc)
        navigation.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        navigation.modalPresentationStyle = .custom
        navigation.transitioningDelegate = vc
        present(navigation, animated: true, completion: nil)
    }
    
    // MARK: - Images
    @objc func didChooseImageFromGallery(_ image: UIImage, description: String? = nil) {
        fatalError("Must override")
    }
    
    @objc func didAddLink(_ urlString: String, placeholder: String? = nil) {
        fatalError("Must override")
    }
    
    // MARK: - Immutable actions
    @objc func shouldSaveDraft() -> Bool {
        viewModel.postForEdit == nil && !contentTextView.text.isEmpty
    }
    @objc override func close() {
        guard shouldSaveDraft() else {
            back()
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
                } else if index == 1 {
                    // remove draft if exists
                    self.removeDraft()
                    
                    // close
                    self.dismiss(animated: true, completion: nil)
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
    
    @objc func chooseFromGallery() {
        let pickerVC = SinglePhotoPickerVC()
        pickerVC.completion = { image in
            let alert = UIAlertController(
                title: "description".localized().uppercaseFirst,
                message: "add a description for your image".localized().uppercaseFirst,
                preferredStyle: .alert)
            
            alert.addTextField { field in
                field.placeholder = "description".localized().uppercaseFirst + "(" + "optional".localized() + ")"
            }
            
            alert.addAction(UIAlertAction(title: "add".localized().uppercaseFirst, style: .cancel, handler: { _ in
                self.didChooseImageFromGallery(image, description: alert.textFields?.first?.text)
                pickerVC.dismiss(animated: true, completion: nil)
            }))
            
            pickerVC.present(alert, animated: true, completion: nil)
        }
        self.present(pickerVC, animated: true, completion: nil)
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
        let currentSelectedRange = contentTextView.selectedRange
        if let urlString = contentTextView.currentTextStyle.value.urlString {
            // Remove link that is not a mention or tag
            if urlString.isLink {
                showActionSheet(title: urlString, message: nil, actions: [
                    UIAlertAction(title: "remove".localized().uppercaseFirst, style: .destructive, handler: { (_) in
                        self.contentTextView.removeLink()
                    })
                ])
            }
            
        } else {
            // Add link
            let alert = UIAlertController(
                title: "add link".localized().uppercaseFirst,
                message: "select a link to add to text".localized().uppercaseFirst,
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
    @objc override func send() {
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
                return self.viewModel.sendPost(title: self.postTitle, block: block)
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
                    guard let communityId = self.viewModel.community.value?.communityId else {return}
                    let postPageVC = PostPageVC(userId: userId, permlink: permlink, communityId: communityId)
                    self.dismiss(animated: true) {
                        UIApplication.topViewController()?.show(postPageVC, sender: nil)
                    }
                }
            }) { (error) in
                self.hideHud()
                let message = "post not found".localized().uppercaseFirst
                if let error = error as? ErrorAPI {
                    switch error {
                    case .responseUnsuccessful(message: message):
                        self.dismiss(animated: true, completion: nil)
                    case .blockchain(message: let message):
                        self.showAlert(title: "error".localized().uppercaseFirst, message: message)
                    default:
                        break
                    }
                }
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func previewAttachment(_ attachment: TextAttachment) {
        guard let type = attachment.attributes?.type else {return}
        
        switch type {
        case "website", "video":
            guard let urlString = attachment.attributes?.url,
                let url = URL(string: urlString) else {return}
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        case "image":
//            if let localImage = attachment.localImage {
//                let appImage = ViewerImage.appImage(forImage: localImage)
//                let viewer = AppImageViewer(photos: [appImage])
//                present(viewer, animated: false, completion: nil)
//            } else if let imageUrl = attachment.attributes?.url,
//                let url = URL(string: imageUrl) {
//                NetworkService.shared.downloadImage(url)
//                    .subscribe(onSuccess: { [weak self] (image) in
//                        let appImage = ViewerImage.appImage(forImage: image)
//                        let viewer = AppImageViewer(photos: [appImage])
//
//                        self?.present(viewer, animated: false, completion: nil)
//                        }, onError: {[weak self] (error) in
//                            self?.showError(error)
//                    })
//                    .disposed(by: self.disposeBag)
//            }
            break
        default:
            break
        }
    }
    
    // MARK: - Add link
    func addAgeLimit() {
        //TODO: Change func
        showAlert(title: "info".localized().uppercaseFirst, message: "add age limit 18+ (coming soon)".localized().uppercaseFirst, buttonTitles: ["OK".localized()], highlightedButtonIndex: 0)
    }
}

extension PostEditorVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
