//
//  EditorVC+CollectionViewFlowLayoutDelegate.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = tools.value[indexPath.row]
        let height: CGFloat = 35
        var width: CGFloat = 35
        
        if let desc = item.description?.localized().uppercaseFirst {
            width = 2.0 * EditorToolbarItemCell.padding +
                EditorToolbarItemCell.separatorSpace +
                item.iconSize.width +
                desc.nsString.size(withAttributes: [
                    .font : UIFont.systemFont(ofSize: EditorToolbarItemCell.fontSize, weight: EditorToolbarItemCell.fontWeight)
                    ]).width
        }
        return CGSize(width: width, height: height)
    }
}
