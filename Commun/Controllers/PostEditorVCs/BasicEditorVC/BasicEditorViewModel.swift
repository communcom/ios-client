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

class BasicEditorViewModel: PostEditorViewModel {
    let attachments = BehaviorRelay<[TextAttachment]>(value: [])
    
    func addAttachment(_ attachment: TextAttachment) {
        var value = attachments.value
        value.append(attachment)
        attachments.accept(value)
    }
    
    func removeAttachment(_ attachment: TextAttachment) {
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
