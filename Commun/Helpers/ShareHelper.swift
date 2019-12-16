//
//  ShareHelper.swift
//  Commun
//
//  Created by Artem Shilin on 21.11.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

struct ShareHelper {
    static func share(post: ResponseAPIContentGetPost?) {
        guard let topController = UIApplication.topViewController(), let post = post else { return }
        var urlString = Config.appConfig?.domain ?? "https://commun.com"

        if let shareLink = post.url {
            urlString += shareLink
        }

        if let url = URL(string: urlString) {
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            topController.present(activity, animated: true)
        }
    }
}
