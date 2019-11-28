//
//  CommentForm+Actions.swift
//  Commun
//
//  Created by Chung Tran on 11/19/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

extension CommentForm {
    @objc func sendComment() {
        if mode != .new && parentComment == nil { return}
        
        #warning("send image")
        var block: ResponseAPIContentBlock!
        textView.getContentBlock()
            .observeOn(MainScheduler.instance)
            .flatMap { parsedBlock -> Single<SendPostCompletion> in
                //clean
                block = parsedBlock
                block.maxId = nil
                
                // send new comment
                let request: Single<SendPostCompletion>
                switch self.mode {
                case .new:
                    request = self.viewModel.sendNewComment(block: block)
                case .edit:
                    request = self.viewModel.updateComment(self.parentComment!, block: block)
                case .reply:
                    request = self.viewModel.replyToComment(self.parentComment!, block: block)
                }
                
                return request
            }
            .subscribe(onSuccess: { [weak self] _ in
                self?.textView.text = ""
                self?.mode = .new
                self?.parentComment = nil
                self?.endEditing(true)
                
            }) { (error) in
//                self.setLoading(false)
                self.parentViewController?.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
