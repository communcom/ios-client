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
        
        viewModel.sendPost(with: titleTextView.text, text: contentTextView.attributedText)
            .do(onSubscribe: {
                self.navigationController?.showIndetermineHudWithMessage("sending post".localized().uppercaseFirst)
            })
            .flatMap { (transactionId, userId, permlink) -> Single<(userId: String, permlink: String)> in
                guard let id = transactionId,
                    let userId = userId,
                    let permlink = permlink else {
                        return .error(ErrorAPI.responseUnsuccessful(message: "post not found".localized().uppercaseFirst))
                }
                
                self.navigationController?.showIndetermineHudWithMessage("wait for transaction".localized().uppercaseFirst)
                
                return NetworkService.shared.waitForTransactionWith(id: id)
                    .andThen(Single<(userId: String, permlink: String)>.just((userId: userId, permlink: permlink)))
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (userId, permlink) in
                self.navigationController?.hideHud()
                // if editing post
                if var post = self.viewModel?.postForEdit {
                    post.content.title = self.titleTextView.text
                    post.content.body.full = self.contentTextView.text
                    if let imageURL = self.viewModel?.embeds.first(where: {($0["type"] as? String) == "photo"})?["url"] as? String,
                        let embeded = post.content.embeds.first,
                        embeded.type == "photo" {
                        post.content.embeds[0].result?.url = imageURL
                    }
                    post.notifyChanged()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    // show post page
                    let postPageVC = controllerContainer.resolve(PostPageVC.self)!
                    postPageVC.viewModel.permlink = permlink
                    postPageVC.viewModel.userId = userId
                    var viewControllers = self.navigationController!.viewControllers
                    viewControllers[0] = postPageVC
                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                }
            }, onError: { (error) in
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
                
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func closeButtonDidTouch(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func hideKeyboardButtonDidTouch(_ sender: Any) {
        view.endEditing(true)
    }
}
