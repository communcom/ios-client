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
            .do(onSubscribe: {
                self.navigationController?.showIndetermineHudWithMessage("Sending post".localized())
            })
            .flatMap({ (transactionId, userId, permlink) -> Single<(userId: String, permlink: String)> in
                guard let id = transactionId,
                    let userId = userId,
                    let permlink = permlink else {
                        return .error(ErrorAPI.responseUnsuccessful(message: "Post Not Found"))
                }
                
                self.navigationController?.showIndetermineHudWithMessage("Wait for transaction".localized())
                return NetworkService.shared.waitForTransactionWith(id: id)
                    .andThen(Single<(userId: String, permlink: String)>.just((userId: userId, permlink: permlink)))
            })
            .subscribe(onSuccess: { (userId, permlink) in
                self.navigationController?.hideHud()
                
                // show post page
                let postPageVC = controllerContainer.resolve(PostPageVC.self)!
                postPageVC.viewModel.permlink = permlink
                postPageVC.viewModel.userId = userId
                var viewControllers = self.navigationController!.viewControllers
                viewControllers[0] = postPageVC
                self.navigationController?.setViewControllers(viewControllers, animated: true)
            }, onError: { (error) in
                self.navigationController?.hideHud()
                
                if let error = error as? ErrorAPI {
                    switch error {
                    case .responseUnsuccessful(message: "Post Not Found"):
                        self.dismiss(animated: true, completion: nil)
                        break
                    default:
                        self.showGeneralError()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func closeButtonDidTouch(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
