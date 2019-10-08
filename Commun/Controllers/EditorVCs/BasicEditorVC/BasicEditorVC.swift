//
//  BasicEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import PureLayout
import RxCocoa
import RxSwift

class BasicEditorVC: EditorVC {
    // MARK: - Subviews
    var _contentTextView = BasicEditorTextView(forExpandable: ())
    override var contentTextView: ContentTextView {
        return _contentTextView
    }
    var attachmentsView = AttachmentsView(forAutoLayout: ())
    
    // MARK: - Override
    override var contentCombined: Observable<Void> {
        return contentTextView.rx.text.orEmpty.map {_ in ()}
    }
    
    override var postTitle: String? {
        return nil
    }
    
    var _viewModel = BasicEditorViewModel()
    override var viewModel: EditorViewModel {
        return _viewModel
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel.postForEdit == nil {
            appendTool(EditorToolbarItem.addArticle)
        }
    }
    
    override func layoutTopContentTextView() {
        contentTextView.autoPinEdge(.top, to: .bottom, of: communityAvatarImage, withOffset: 20)
    }
    
    override func layoutBottomContentTextView() {
        contentTextView.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    override func bind() {
        super.bind()
        
        bindAttachments()
    }
    
    // MARK: - overriding actions
    override func addArticle() {
        weak var presentingViewController = self.presentingViewController
        let attrStr = contentTextView.attributedText
        dismiss(animated: true, completion: {
            let vc = ArticleEditorVC()
            vc.modalPresentationStyle = .fullScreen
            presentingViewController?.present(vc, animated: true, completion: {
                vc.contentTextView.attributedText = attrStr
            })
        })
    }
    
    override func didChooseImageFromGallery(_ image: UIImage, description: String? = nil) {
        
        var embed = try! ResponseAPIFrameGetEmbed(
            blockAttributes: ContentBlockAttributes(
                description: description
            )
        )
        embed.type = "image"
        
        let attachment = TextAttachment()
        attachment.embed = embed
        attachment.localImage = image
        
        // Add embeds
        _viewModel.addAttachment(attachment)
    }
    
    override func didAddImageFromURLString(_ urlString: String, description: String? = nil) {
        var embed = try! ResponseAPIFrameGetEmbed(
            blockAttributes: ContentBlockAttributes(
                url: urlString, description: description
            )
        )
        embed.type = "image"
        
        let attachment = TextAttachment()
        attachment.embed = embed
        
        _viewModel.addAttachment(attachment)
    }
    
    override func didAddLink(_ urlString: String, placeholder: String? = nil) {
        if let placeholder = placeholder,
            !placeholder.isEmpty
        {
            _contentTextView.addLink(urlString, placeholder: placeholder)
        }
        else {
            parseLink(urlString)
        }
        
    }
    
    override func getContentBlock() -> Single<ContentBlock> {
        // TODO: - Attachments
        super.getContentBlock()
//            .flatMap {contentBlock -> Single<ContentBlock> in
//                // transform attachments to contentBlock
//                self._viewModel.attachments.value.compactMap { (attachment) -> Single<ContentBlock>? in
//                    <#code#>
//                }
//            }
    }
}
