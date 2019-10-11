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
        let showArticleVC = {[weak self] in
            weak var presentingViewController = self?.presentingViewController
            let attrStr = self?.contentTextView.attributedText
            self?.dismiss(animated: true, completion: {
                let vc = ArticleEditorVC()
                vc.modalPresentationStyle = .fullScreen
                presentingViewController?.present(vc, animated: true, completion: {
                    vc.contentTextView.attributedText = attrStr
                })
            })
        }
        
        if contentTextView.text.isEmpty {
            showArticleVC()
        }
        else {
            showAlert(title: "add article".localized().uppercaseFirst, message: "override current work and add a new article".localized().uppercaseFirst + "?", buttonTitles: ["OK".localized(), "cancel".localized().uppercaseFirst], highlightedButtonIndex: 0) { (index) in
                if index == 0 {
                    showArticleVC()
                }
            }
        }
    }
    
    override func didChooseImageFromGallery(_ image: UIImage, description: String? = nil) {
        
        var embed = try! ResponseAPIFrameGetEmbed(
            blockAttributes: ResponseAPIContentBlockAttributes(
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
    
//    override func didAddImageFromURLString(_ urlString: String, description: String? = nil) {
//        parseLink(urlString)
//    }
    
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
    
    override func getContentBlock() -> Single<ResponseAPIContentBlock> {
        // TODO: - Attachments
        var block: ResponseAPIContentBlock?
        var id: UInt64!
        return super.getContentBlock()
            .flatMap {contentBlock -> Single<[ResponseAPIContentBlock]> in
                block = contentBlock
                // transform attachments to contentBlock
                id = (contentBlock.maxId ?? 100) + 1
                var childId = id!
                
                return Single.zip(self._viewModel.attachments.value.compactMap { (attachment) -> Single<ResponseAPIContentBlock>? in
                    return attachment.toSingleContentBlock(id: &childId)
                })
            }
            .map {contentBlocks -> ResponseAPIContentBlock in
                guard var childs = block?.content.arrayValue else {return block!}
                childs.append(ResponseAPIContentBlock(id: id, type: "attachments", attributes: nil, content: .array(contentBlocks)))
                block!.content = .array(childs)
                
                return block!
            }
    }
}
