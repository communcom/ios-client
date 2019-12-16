//
//  PhotoLibraryCell.swift
//  Commun
//
//  Created by Chung Tran on 24/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import Photos

class PhotoLibraryCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        option.isSynchronous = true
    }
    
    override init(frame: CGRect) {
        fatalError("Did not implement")
    }
    
    func setUp(with asset: PHAsset) {
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: option) { (image, _) in
            self.imageView.image = image
        }
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        super.prepareForReuse()
    }
}
