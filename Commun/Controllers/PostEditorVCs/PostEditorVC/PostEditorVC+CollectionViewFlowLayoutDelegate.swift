//
//  PostEditorVC+CollectionViewFlowLayoutDelegate.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension PostEditorVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = tools.value[indexPath.row]
        let height: CGFloat = 35
        var width: CGFloat = 35
        
        if let desc = item.description?.localized().uppercaseFirst {
            width = 2.0 * PostEditorToolbarItemCell.padding +
                PostEditorToolbarItemCell.separatorSpace +
                item.iconSize.width +
                desc.nsString.size(withAttributes: [
                    .font : UIFont.systemFont(ofSize: PostEditorToolbarItemCell.fontSize, weight: PostEditorToolbarItemCell.fontWeight)
                    ]).width
        }
        return CGSize(width: width, height: height)
    }
}
