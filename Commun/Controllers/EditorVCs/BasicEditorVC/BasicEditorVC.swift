//
//  BasicEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/3/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class BasicEditorVC: CommonEditorVC {
    // MARK: - Outlets
    @IBOutlet weak var _contentTextView: BasicEditorTextView!
    override var contentTextView: BasicEditorTextView {
        return _contentTextView
    }
    
    // MARK: - Properties
    override var contentCombined: Observable<[Any]>! {
        return contentTextView.rx.text.orEmpty
            .map {[$0]}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func verify() -> Bool {
        let content = contentTextView.text ?? ""
    
        // both title and content are not empty
        let contentAreNotEmpty = !content.isEmpty
        
        // compare content
        let contentChanged = (self.contentTextView.attributedText != self.contentTextView.originalAttributedString)
        
        // reassign result
        return contentAreNotEmpty && contentChanged
    }
}
