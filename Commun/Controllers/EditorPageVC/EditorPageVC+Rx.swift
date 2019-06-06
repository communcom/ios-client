//
//  EditorPageVC+Rx.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 08/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension EditorPageVC {
    
    func bindUI() {
        guard let viewModel = viewModel else {return}
        // isAdult
        adultButton.rx.tap
            .map {_ in !viewModel.isAdult.value}
            .bind(to: viewModel.isAdult)
            .disposed(by: disposeBag)
        
        viewModel.isAdult
            .map {$0 ? "18ButtonSelected": "18Button"}
            .map {UIImage(named: $0)}
            .bind(to: self.adultButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
        // verification
        
        #warning("Verify community")
        #warning("fix contentText later")
        let combinedText = Observable.combineLatest(titleTextView.rx.text.orEmpty, contentTextView.rx.text.orEmpty).share()
        
        combinedText
            .map {
                // Text field  is not empty
                (!$0.0.isEmpty) && (!$0.1.isEmpty) &&
                // Title or content has changed
                ($0.0 != viewModel.postForEdit?.content.title ||
                $0.1 != viewModel.postForEdit?.content.body.preview)
            }
            .bind(to: sendPostButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // send post button
        sendPostButton.rx.tap
            .withLatestFrom(combinedText)
            .flatMap {title, content in
                return viewModel.sendPost(with: title, text: content)
                    .do(onSubscribe: {
                        self.navigationController?.showIndetermineHudWithMessage("Sending post".localized())
                    })
            }
            .flatMap { (transactionId, userId, permlink) -> Single<(userId: String, permlink: String)> in
                guard let id = transactionId,
                    let userId = userId,
                    let permlink = permlink else {
                        return .error(ErrorAPI.responseUnsuccessful(message: "Post Not Found"))
                }
                
                self.navigationController?.showIndetermineHudWithMessage("Wait for transaction".localized())
                return NetworkService.shared.waitForTransactionWith(id: id)
                    .andThen(Single<(userId: String, permlink: String)>.just((userId: userId, permlink: permlink)))
            }
            .subscribe(onNext: { (userId, permlink) in
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
    
}
