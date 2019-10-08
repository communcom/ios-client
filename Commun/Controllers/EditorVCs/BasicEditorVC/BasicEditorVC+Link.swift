//
//  BasicEditorVC+Link.swift
//  Commun
//
//  Created by Chung Tran on 10/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension BasicEditorVC {
    func parseLink(_ link: String) {
        // detect link type
        NetworkService.shared.getEmbed(url: link)
            .do(onSubscribe: {
                self.showIndetermineHudWithMessage(
                        "loading".localized().uppercaseFirst)
            })
            .subscribe(onSuccess: {[weak self] embed in
                self?.hideHud()
                self?.addEmbed(embed)
            }, onError: {error in
                self.hideHud()
                self.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func addEmbed(_ embed: ResponseAPIFrameGetEmbed) {
        guard let single = embed.toTextAttachmentSingle() else {return}
        
        single
            .do(onSubscribe: {
                self.showIndetermineHudWithMessage(
                    "loading".localized().uppercaseFirst)
            })
            .subscribe(
                onSuccess: { [weak self] (attachment) in
                    guard let strongSelf = self else {return}
                    strongSelf.hideHud()
                    strongSelf._viewModel.addAttachment(attachment)
                },
                onError: {[weak self] error in
                    self?.hideHud()
                    self?.showError(error)
                }
            )
            .disposed(by: disposeBag)
    }
}
