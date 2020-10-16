//
//  ResponseAPIContentGetPost.swift
//  Commun
//
//  Created by Chung Tran on 6/22/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension ResponseAPIContentGetPost {
    func shouldUpdateHeightForPostWithUpdatedPost(_ updatedPost: ResponseAPIContentGetPost?) -> Bool {
        if let updatedItem = updatedPost {
            if document != updatedItem.document {
                return true
            }
            if topExplanation != updatedItem.topExplanation {
                return true
            }
            if bottomExplanation != updatedItem.bottomExplanation {
                return true
            }
            if attachments != updatedItem.attachments {
                return true
            }
        }
        return false
    }
}
