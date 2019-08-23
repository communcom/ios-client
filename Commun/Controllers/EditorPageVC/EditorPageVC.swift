//
//  EditorPageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 29/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class EditorPageVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextView: ExpandableTextView!
    @IBOutlet weak var contentTextView: ExpandableTextView!
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var adultButton: UIButton!
    @IBOutlet weak var sendPostButton: UIBarButtonItem!
    
    // MARK: - Properties
    var viewModel: EditorPageViewModel?
    let disposeBag = DisposeBag()
    lazy var defaultAttributeForContentTextView: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.systemFont(ofSize: 17)]
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if viewModel == nil {
            viewModel = EditorPageViewModel()
        }
        
        self.title = (viewModel?.postForEdit != nil ? "edit post" : "create post").localized().uppercaseFirst
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        
        dropDownView.layer.borderWidth = 1.0
        dropDownView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        
        titleTextView.textContainerInset = UIEdgeInsets.zero
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.placeholder = "title placeholder".localized().uppercaseFirst
        
        contentTextView.textContainerInset = UIEdgeInsets.zero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.placeholder = "write text placeholder".localized().uppercaseFirst + "..."
        contentTextView.typingAttributes = defaultAttributeForContentTextView
        
        previewView.adjustHeight(0)
        
        // if editing post
        if let post = viewModel?.postForEdit {
            titleTextView.rx.text.onNext(post.content.title)
            #warning("change text later")
            contentTextView.rx.text.onNext(post.content.body.full ?? post.content.body.preview)
            
            if let firstEmbeded = post.content.embeds.first?.result {
                if firstEmbeded.type == "photo" {
                    let value = PreviewView.MediaType.image(image: nil, url: firstEmbeded.url)
                    previewView.initialMedia = value
                    previewView.setUp(mediaType: value)
                } else {
                    let value = PreviewView.MediaType.linkFromText(text: firstEmbeded.url)
                    previewView.initialMedia = value
                    previewView.setUp(mediaType: value)
                }
            }
        }
        
        bindUI()
    }
}
