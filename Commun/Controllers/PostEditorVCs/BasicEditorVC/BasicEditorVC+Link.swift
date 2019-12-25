//
//  BasicEditorVC+Link.swift
//  Commun
//
//  Created by Chung Tran on 10/8/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension BasicEditorVC {
    func parseLink(_ link: String) {
        // detect link type
        NetworkService.shared.getEmbed(url: link)
            .do(onSubscribe: {
                self.attachmentView.showLoading()
            })
            .subscribe(onSuccess: {[weak self] embed in
                self?.attachmentView.hideLoading()
                self?.addEmbed(embed)
            }, onError: {[weak self] error in
                self?.attachmentView.hideLoading()
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func addEmbed(_ embed: ResponseAPIFrameGetEmbed) {
        guard let single = embed.toTextAttachmentSingle(withSize: CGSize(width: contentTextView.size.width, height: attachmentHeight), forTextView: _contentTextView) else {return}
        
        single
            .do(onSubscribe: {
                self.attachmentView.showLoading()
            })
            .subscribe(
                onSuccess: { [weak self] (attachment) in
                    self?.attachmentView.hideLoading()
                    self?._viewModel.attachment.accept(attachment)
                },
                onError: {[weak self] error in
                    self?.attachmentView.hideLoading()
                    self?.showError(error)
                }
            )
            .disposed(by: disposeBag)
    }
}
