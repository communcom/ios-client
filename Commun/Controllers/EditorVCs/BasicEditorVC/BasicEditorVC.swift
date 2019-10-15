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
    // MARK: - Constants
    let attachmentHeight: CGFloat = 300
    let attachmentDraftKey = "BasicEditorVC.attachmentDraftKey"
    
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
    
    // MARK: - overriding actions
    
    override func didChooseImageFromGallery(_ image: UIImage, description: String? = nil) {
        
        var embed = try! ResponseAPIFrameGetEmbed(
            blockAttributes: ResponseAPIContentBlockAttributes(
                description: description
            )
        )
        embed.type = "image"
        
        let attachment = TextAttachment(embed: embed, localImage: image, size: CGSize(width: view.size.width, height: attachmentHeight))
        attachment.delegate = self
        
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
