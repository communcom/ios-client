//
//  NetworkService.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import RxSwift
import Foundation
import CyberSwift
import SwifterSwift
import SDWebImage

class NetworkService: NSObject {
    // MARK: - Properties
    static let shared = NetworkService()
    
    // MARK: - Contract `gls.social`
    func downloadImage(_ url: URL) -> Single<UIImage> {
        Logger.log(message: "Downloading image for \(url.absoluteString)", event: .debug)
        return Single<UIImage>.create {single in
            SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { (image, _, error, _, _, _) in
                if let image = image {
                   single(.success(image))
                   return
               }
               if let error = error {
                   single(.error(error))
                   return
               }
               single(.error(CMError.unknown))
            }
            return Disposables.create()
        }
    }
}
