//
//  Contact.swift
//  Commun
//
//  Created by Chung Tran on 7/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

enum Contact: String {
    enum IdentifyType: String {
        case phoneNumber = "phone number"
        case username = "username"
        case link = "link"
    }
    
    case wechat
    case facebook
    case telegram
    case whatsapp
    case instagram
    case linkedin
    case twitter
    case github
    case website_url
    
    var identifiedBy: IdentifyType {
        switch self {
        case .wechat, .facebook, .instagram, .linkedin, .twitter, .github:
            return .username
        case .telegram, .whatsapp:
            return .phoneNumber
        case .website_url:
            return .link
        }
    }
}

class ContactTextField: UITextField {
    let contact: Contact
    
    init(contact: Contact) {
        self.contact = contact
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setUp()
    }
    
    func setUp() {
        borderStyle = .none
        font = .systemFont(ofSize: 17, weight: .semibold)
        
        switch contact.identifiedBy {
        case .username:
            leftView = UILabel.with(text: "@", textSize: 17, weight: .semibold)
            leftViewMode = .always
        default:
            break
        }
        
        autocapitalizationType = .none
        placeholder = ("your " + contact.identifiedBy.rawValue).localized().uppercaseFirst
    }
    
    func verify() -> Bool {
        guard let text = text else {return false}
        switch contact.identifiedBy {
        case .username:
            return text.count >= 3
            // verify username
        case .phoneNumber:
            fatalError("TODO: Choose region, phone number")
            // verify phone number
        case .link:
            return text.isLink
        }
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
