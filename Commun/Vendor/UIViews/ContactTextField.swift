//
//  Contact.swift
//  Commun
//
//  Created by Chung Tran on 7/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class ContactTextField: UITextField {
    let contactType: ResponseAPIContentGetProfilePersonal.LinkType
    var isValid = false
    
    init(contactType: ResponseAPIContentGetProfilePersonal.LinkType) {
        self.contactType = contactType
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setUp()
    }
    
    func setUp() {
        borderStyle = .none
        font = .systemFont(ofSize: 17, weight: .semibold)
        
        switch contactType.identifiedBy {
        case .username:
            leftView = UILabel.with(text: "@", textSize: 17, weight: .semibold)
            leftViewMode = .always
        default:
            break
        }
        
        autocorrectionType = .no
        autocapitalizationType = .none
        placeholder = ("your " + contactType.identifiedBy.rawValue).localized().uppercaseFirst
    }
    
    @discardableResult
    func verify() -> Bool {
        guard let text = text else {
            isValid = false
            return false
        }
        switch contactType.identifiedBy {
        case .username:
            isValid = text.count >= 3
            // verify username
        case .phoneNumber:
            fatalError("TODO: Choose region, phone number")
            // verify phone number
        case .link:
            isValid = text.isLink
        }
        return isValid
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: ContactTextField {
    var isValid: Observable<Bool> {
        text.orEmpty.map {_ in self.base.verify()}
    }
}
