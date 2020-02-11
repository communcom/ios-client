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
        // embed loading placeholder view
        let loadingView: UIView = {
            let view = UIView(backgroundColor: .f3f5fa)
            
            let loadingEmbedLabel = UILabel.with(text: "loading embed".localized().uppercaseFirst + "...", textSize: 15, weight: .semibold)
            view.addSubview(loadingEmbedLabel)
            loadingEmbedLabel.autoPinTopAndLeadingToSuperView(inset: 16)
            
            let linkLabel = UILabel.with(text: link, textSize: 15)
            view.addSubview(linkLabel)
            linkLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .top)
            linkLabel.autoPinEdge(.top, to: .bottom, of: loadingEmbedLabel, withOffset: 16)
            
            return view
        }()
        
        self.attachmentView.removeSubviews()
        self.attachmentView.addSubview(loadingView)
        loadingView.autoPinEdgesToSuperviewEdges()
        
        // detect link type
        NetworkService.shared.getEmbed(url: link)
            .flatMap {
                $0.toTextAttachmentSingle(withSize: CGSize(width: self.contentTextView.size.width, height: self.attachmentHeight), forTextView: self._contentTextView) ?? .error(ErrorAPI.unknown)
            }
            .subscribe(onSuccess: {[weak self] attachment in
                self?.attachmentView.removeSubviews()
                self?._viewModel.attachment.accept(attachment)
            }, onError: {[weak self] error in
                self?.attachmentView.removeSubviews()
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
}
