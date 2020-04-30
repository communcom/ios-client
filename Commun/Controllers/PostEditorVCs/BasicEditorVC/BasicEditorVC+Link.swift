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
            let view = UIView(backgroundColor: .appLightGrayColor)
            
            let loadingEmbedLabel = UILabel.with(text: "loading embed".localized().uppercaseFirst + "...", textSize: 15, weight: .semibold)
            view.addSubview(loadingEmbedLabel)
            loadingEmbedLabel.autoPinTopAndLeadingToSuperView(inset: 16)
            
            let indicator = UIActivityIndicatorView(forAutoLayout: ())
            indicator.color = .appGrayColor
            view.addSubview(indicator)
            indicator.autoPinEdge(.leading, to: .trailing, of: loadingEmbedLabel, withOffset: 5)
            indicator.autoAlignAxis(.horizontal, toSameAxisOf: loadingEmbedLabel)
            indicator.startAnimating()
            
            let closeButton = UIButton.close()
            view.addSubview(closeButton)
            closeButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
            closeButton.autoAlignAxis(.horizontal, toSameAxisOf: loadingEmbedLabel)
            
            closeButton.addTarget(self, action: #selector(forceDeleteEmbed), for: .touchUpInside)
            
            let linkLabel = UILabel.with(text: link, textSize: 15)
            view.addSubview(linkLabel)
            linkLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .top)
            linkLabel.autoPinEdge(.top, to: .bottom, of: loadingEmbedLabel, withOffset: 16)
            
            return view
        }()
        
        // for button
        forcedDeleteEmbed = false
        
        // show loading
        self.attachmentView.removeSubviews()
        self.attachmentView.addSubview(loadingView)
        loadingView.autoPinEdgesToSuperviewEdges()
        
        // detect link type
        RestAPIManager.instance.getEmbed(url: link)
            .flatMap {
                $0.toTextAttachmentSingle(withSize: CGSize(width: self.contentTextView.size.width, height: self.attachmentHeight), forTextView: self._contentTextView) ?? .error(CMError.unknown)
            }
            .subscribe(onSuccess: {[weak self] attachment in
                if self?.forcedDeleteEmbed == true {return}
                self?.attachmentView.removeSubviews()
                self?._viewModel.attachment.accept(attachment)
            }, onError: {[weak self] error in
                if self?.forcedDeleteEmbed == true {return}
                self?.attachmentView.removeSubviews()
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    @objc func forceDeleteEmbed() {
        forcedDeleteEmbed = true
        self._viewModel.attachment.accept(nil)
        self.link = nil
    }
}
