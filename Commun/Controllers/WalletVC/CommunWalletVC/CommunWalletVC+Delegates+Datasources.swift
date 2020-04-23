//
//  CommunWalletVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 4/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

// MARK: - UICollectionViewDelegateFlowLayout
extension CommunWalletVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == sendPointsCollectionView {
            return CGSize(width: 90, height: SendPointCollectionCell.height)
        }
        return CGSize(width: 140, height: MyPointCollectionCell.height)
    }
}

extension CommunWalletVC: CommunWalletHeaderViewDatasource {
    func data(forWalletHeaderView headerView: CommunWalletHeaderView) -> [ResponseAPIWalletGetBalance]? {
        balances
    }
}
