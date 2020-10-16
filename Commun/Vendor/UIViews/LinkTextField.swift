//
//  Contact.swift
//  Commun
//
//  Created by Chung Tran on 7/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class LinkTextField: UITextField {
    let linkType: ResponseAPIContentGetProfilePersonalLinks.LinkType
    var isValid = false
    
    init(linkType: ResponseAPIContentGetProfilePersonalLinks.LinkType) {
        self.linkType = linkType
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setUp()
    }
    
    func setUp() {
        borderStyle = .none
        font = .systemFont(ofSize: 17, weight: .semibold)
        
        leftView = UILabel.with(text: "@", textSize: 17, weight: .semibold)
        leftViewMode = .always
        
        autocorrectionType = .no
        autocapitalizationType = .none
        placeholder = "your username".localized().uppercaseFirst
    }
    
    @discardableResult
    func verify() -> Bool {
        guard let text = text else {
            isValid = false
            return false
        }
        isValid = text.count >= 3
        return isValid
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: LinkTextField {
    var isValid: Observable<Bool> {
        text.orEmpty.map {_ in self.base.verify()}
    }
}
