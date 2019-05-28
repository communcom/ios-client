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
    
    let imagePicker = UIImagePickerController()
    
    var cells: [UITableViewCell] = []
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if viewModel == nil {
            viewModel = EditorPageViewModel()
        }
        
        self.title = "Create post"
        
        let close = UIButton(type: .custom)
        close.setTitle("Close", for: .normal)
        close.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        close.setTitleColor(#colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1), for: .normal)
        close.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        close.accessibilityLabel = "EditorPageCloseButton"
        close.accessibilityIdentifier = "EditorPageCloseButton"
        let closeItem = UIBarButtonItem(customView: close)
        
        let post = UIButton(type: .custom)
        post.setTitle("Post", for: .normal)
        post.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        post.setTitleColor(#colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1), for: .normal)
        post.addTarget(self, action: #selector(postButtonTap), for: .touchUpInside)
        post.accessibilityLabel = "EditorPagePostButton"
        post.accessibilityIdentifier = "EditorPagePostButton"
        let postItem = UIBarButtonItem(customView: post)
        
        self.navigationItem.setLeftBarButtonItems([closeItem], animated: true)
        self.navigationItem.setRightBarButtonItems([postItem], animated: true)
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        
        dropDownView.layer.borderWidth = 1.0
        dropDownView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        dropDownView.layer.cornerRadius = 12.0
        
        titleTextField.placeholder = "Title".localized()
        titleTextField.delegate = self
        contentTextView.placeholder = "Enter text".localized() + "..."
        contentTextView.delegate = self
        
        makeSubscriptions()
    }
 
    @objc func closeView() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
