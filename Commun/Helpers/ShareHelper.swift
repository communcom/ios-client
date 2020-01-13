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
        guard let post = post else {return}
        var urlString = Config.appConfig?.domain ?? "https://commun.com"

        if let shareLink = post.url {
            urlString += shareLink
        }

        share(urlString: urlString)
    }
    
    static func share(urlString: String) {
        guard let topController = UIApplication.topViewController() else { return }
        if let url = URL(string: urlString) {
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            topController.present(activity, animated: true)
        }
    }
    
    static func share(image: UIImage) {
        guard let topController = UIApplication.topViewController() else { return }
        let avc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        topController.present(avc, animated: true, completion: nil)
    }
}
