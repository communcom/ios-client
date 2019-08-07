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

    var viewModel: EditorPageViewModel?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextView: ExpandableTextView!
    @IBOutlet weak var contentTextView: ExpandableTextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var adultButton: UIButton!
    
    @IBOutlet weak var sendPostButton: UIBarButtonItem!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var removeImageButtonHeightConstraint: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if viewModel == nil {
            viewModel = EditorPageViewModel()
        }
        
        self.title = viewModel?.postForEdit != nil ? "Edit post".localized() : "Create post".localized()
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        
        dropDownView.layer.borderWidth = 1.0
        dropDownView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        
        titleTextView.textContainerInset = UIEdgeInsets.zero
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.placeholder = "Title Placeholder".localized()
        
        contentTextView.textContainerInset = UIEdgeInsets.zero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.placeholder = "Write Text Placeholder".localized() + "..."
        
        // if editing post
        if let post = viewModel?.postForEdit {
            titleTextView.rx.text.onNext(post.content.title)
            #warning("change text later")
            contentTextView.rx.text.onNext(post.content.body.full ?? post.content.body.preview)
            
            if let imageURL = post.firstEmbedImageURL {
                imageView.sd_setImage(with: URL(string: imageURL), completed: nil)
                viewModel?.addImage(with: imageURL)
            }
        }
        
        bindUI()
    }
}
