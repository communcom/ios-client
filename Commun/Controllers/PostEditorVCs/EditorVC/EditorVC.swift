//
//  EditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/30/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EditorVC: UIViewController {
    // MARK: - Constant
    
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let tools = BehaviorRelay<[EditorToolbarItem]>(value: [])
    
    // MARK: - Computed properties
    var contentLettersLimit: UInt {
        fatalError("must override")
    }
    var contentCombined: Observable<Void> {
        fatalError("Must override")
    }
    var isContentValid: Bool {
        fatalError("Must override")
    }
    
    // MARK: - Subviews
    var contentTextView: ContentTextView {
        fatalError("Must override")
    }
    
    
}
