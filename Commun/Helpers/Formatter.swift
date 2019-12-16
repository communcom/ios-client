//
//  Formatter.swift
//  Commun
//
//  Created by Artem Shilin on 20.11.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

struct Formatter {
    static func joinedText(with registrationTime: String?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let date = Date.from(string: registrationTime ?? "")
        let dateString = dateFormatter.string(from: date)
        return "joined".localized().uppercaseFirst + " " + "\(dateString)"
    }
}
