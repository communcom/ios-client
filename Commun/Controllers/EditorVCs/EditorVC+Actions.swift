//
//  EditorVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

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
    
    func parsePost(_ post: ResponseAPIContentGetPost) {
        showIndetermineHudWithMessage("loading post".localized().uppercaseFirst)
        // Get full post
        NetworkService.shared.getPost(withPermLink: post.contentId.permlink, forUser: post.contentId.userId)
            .do(onSuccess: { (post) in
                if post.content.body.full == nil {
                    throw ErrorAPI.responseUnsuccessful(message: "Content not found")
                }
            })
            .subscribe(onSuccess: {post in
                self.hideHud()
                self.viewModel.postForEdit = post
                self.setUp(with: post)
            }, onError: {error in
                self.hideHud()
                self.showError(error)
                self.close()
            })
            .disposed(by: disposeBag)
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
}
