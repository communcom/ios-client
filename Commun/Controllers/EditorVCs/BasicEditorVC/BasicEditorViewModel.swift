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
    let attachments = BehaviorRelay<[AttachmentsView.Attachment]>(value: [])
    
    func addAttachment(_ attachment: AttachmentsView.Attachment) {
        var value = attachments.value
        value.removeAll(attachment)
        value.append(attachment)
        attachments.accept(value)
    }
    
    func removeAttachment(_ attachment: AttachmentsView.Attachment) {
        var value = attachments.value
        value.removeAll(attachment)
        attachments.accept(value)
    }
    
    func removeAttachment(at index: Int) {
        var value = attachments.value
        value.remove(at: index)
        attachments.accept(value)
    }
}
