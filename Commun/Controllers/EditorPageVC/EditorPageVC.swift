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
    
    @IBOutlet weak var titleTextField: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var adultButton: UIButton!
    
    @IBOutlet weak var titleTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendPostButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    
    var cells: [UITableViewCell] = []
    
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
        dropDownView.layer.cornerRadius = 12.0
        
        titleTextField.placeholder = "Title".localized()
        titleTextField.delegate = self
        contentTextView.placeholder = "Enter text".localized() + "..."
        contentTextView.delegate = self
        
        // if editing post
        if let post = viewModel?.postForEdit {
            titleTextField.text = post.content.title
            #warning("change text later")
            contentTextView.text = post.content.body.preview
        }
        
        bindUI()
    }
}
