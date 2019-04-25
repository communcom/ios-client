//
//  ResponseAPIContentGetProfilePersonal.swift
//  Commun
//
//  Created by Chung Tran on 25/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ResponseAPIContentGetProfilePersonal {
    var blockchainParams: [String: String?] {
        return [
            "profile_image": self.avatarUrl,
            "cover_image": self.coverUrl,
            "about": self.biography,
            "facebook": self.contacts?.facebook,
            "telegram": self.contacts?.telegram
        ]
    }
}
