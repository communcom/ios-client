//
//  BasicEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PureLayout

class BasicEditorVC: PostEditorVC {
    // MARK: - Constants
    let attachmentHeight: CGFloat = 300
    let attachmentDraftKey = "BasicEditorVC.attachmentDraftKey"
    
    // MARK: - Properties
    var link: String? {
        didSet {
            if link == nil {
                if let indexOfAddArticle = tools.value.firstIndex(of: .addArticle) {
                    insertTool(.addPhoto, at: indexOfAddArticle)
                } else {
                    appendTool(.addPhoto)
                }

            } else {
                removeTool(.addPhoto)
            }
        }
    }
    
    var ignoredLinks = [String]()
    var forcedDeleteEmbed = false
    var shareExtensionData: ShareExtensionData?
    var originalAttachment: TextAttachment?
    
    // MARK: - Subviews
    var _contentTextView = BasicEditorTextView(forExpandable: ())
    override var contentTextView: ContentTextView {
        return _contentTextView
    }
    var attachmentView = UIView(forAutoLayout: ())
    
    // MARK: - Override
    override var contentCombined: Observable<Void> {
        Observable.merge(
            super.contentCombined,
            (viewModel as! BasicEditorViewModel).attachment.map {_ in ()}
        )
    }
    
    override var isContentValid: Bool {
        let isTextValid = super.isContentValid
        // text empty, but attachment exists
        let title = titleTextView.text.trimmed
        let attachmentWithEmptyText = contentTextView.text.trimmed.isEmpty && ((viewModel as! BasicEditorViewModel).attachment.value != nil) && (!title.isEmpty && title.count >= self.titleMinLettersLimit && title.utf8.count <= self.titleBytesLimit)
        
        if !isTextValid && attachmentWithEmptyText && hintType != .chooseCommunity {hintType = nil}
        return isTextValid || attachmentWithEmptyText
    }
    
    var _viewModel = BasicEditorViewModel()
    override var viewModel: PostEditorViewModel {
        return _viewModel
    }
    
    // MARK: - Intializers
    convenience init(shareExtensionData: ShareExtensionData, chooseCommunityAfterLoading: Bool = false) {
        self.init(post: nil, community: nil, chooseCommunityAfterLoading: chooseCommunityAfterLoading, parseDraftAfterLoading: false)
       
        self.shareExtensionData = shareExtensionData
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Share this"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelButtonTapped))
        
        loadShareExtensionData()
    }

    override func setUp() {
        super.setUp()
        
        //TODO: add Article later
//        if viewModel.postForEdit == nil {
//            appendTool(EditorToolbarItem.addArticle)
//        }
    }
    
    override func bind() {
        super.bind()
        
        bindAttachments()
    }
    
    override func didSelectTool(_ item: EditorToolbarItem) {
        super.didSelectTool(item)
        guard item.isEnabled else {return}
        if item == .addArticle {
            addArticle()
        }
    }
    
    override func setUp(with post: ResponseAPIContentGetPost) -> Completable {
        // download image && parse attachments
        var singles = [Single<TextAttachment>]()
        for attachment in post.attachments {
            // get image url or thumbnail (for website or video)
            var imageURL = attachment.content.stringValue ?? attachment.attributes?.url
            if attachment.type == "video" || attachment.type == "website" {
                imageURL = attachment.attributes?.thumbnailUrl
            }
            // return a downloadSingle
            if let urlString = imageURL,
                let url = URL(string: urlString) {
                var attributes = attachment.attributes ?? ResponseAPIContentBlockAttributes(type: attachment.type, url: imageURL)
                attributes.type = attachment.type
                let downloadImage = NetworkService.shared.downloadImage(url)
                    .catchErrorJustReturn(UIImage(named: "image-not-available")!)
                    .map {TextAttachment(attributes: attributes, localImage: $0, size: CGSize(width: self.view.size.width, height: self.attachmentHeight))}
                singles.append(downloadImage)
            }
                // return an error image if thumbnail not found
            else {
                var attributes = attachment.attributes
                attributes?.type = attachment.type
                singles.append(
                    Single<UIImage>.just(UIImage(named: "image-not-available")!)
                        .map {TextAttachment(attributes: attachment.attributes, localImage: $0, size: CGSize(width: self.view.size.width, height: self.attachmentHeight))}
                )
            }
        }
        
        guard singles.count > 0 else {return super.setUp(with: post)}
        
        return super.setUp(with: post)
            .andThen(
                Single.zip(singles)
                    .do(onSuccess: {[weak self] (attachments) in
                        if let attachment = attachments.first {
                            self?.originalAttachment = attachment
                            self?._viewModel.attachment.accept(attachment)
                        }
                    })
                    .flatMapToCompletable()
            )
    }

    // MARK: - GetContentBlock
    override func getContentBlock() -> Single<ResponseAPIContentBlock> {
        var block: ResponseAPIContentBlock?
        var id: UInt64!
        return super.getContentBlock()
            .flatMap {contentBlock -> Single<[ResponseAPIContentBlock]> in
                block = contentBlock
                // transform attachments to contentBlock
                id = (contentBlock.maxId ?? 100) + 1
                var childId = id!
                
                guard let attachment = self._viewModel.attachment.value,
                    let single = attachment.toSingleContentBlock(id: &childId)
                else {
                    return .just([])
                }
                
                return Single.zip([single])
            }
            .map {contentBlocks -> ResponseAPIContentBlock in
                guard var childs = block?.content.arrayValue,
                    contentBlocks.count > 0
                else {return block!}
                childs.append(ResponseAPIContentBlock(id: id, type: "attachments", attributes: nil, content: .array(contentBlocks)))
                block!.content = .array(childs)
                
                return block!
            }
    }
}
