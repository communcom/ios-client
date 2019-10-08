//
//  BasicEditorViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class BasicEditorViewModel: EditorViewModel {
    struct Attachment: Equatable {
        var originalImage: UIImage?
        var urlString: String?
        var description: String?
        
        static func == (lhs: Attachment, rhs: Attachment) -> Bool {
            if lhs.originalImage == rhs.originalImage {return true}
            if lhs.urlString == rhs.urlString {return true}
            return false
        }
    }
    
    let attachments = BehaviorRelay<[Attachment]>(value: [])
    
    func addAttachment(_ attachment: Attachment) {
        var value = attachments.value
        value.removeAll(attachment)
        value.append(attachment)
        attachments.accept(value)
    }
    
    func removeAttachment(_ attachment: Attachment) {
        var value = attachments.value
        value.removeAll(attachment)
        attachments.accept(value)
    }
}
