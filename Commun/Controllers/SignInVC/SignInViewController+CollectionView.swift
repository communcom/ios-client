//
//  SignInViewController+CollectionView.swift
//  Commun
//
//  Created by Chung Tran on 27/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension SignInViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SignInSelectionCell", for: indexPath)
        
        let label = (cell.viewWithTag(1) as! UILabel)
        label.text = selection[indexPath.row]
        
        label.backgroundColor = selected == indexPath.row ? #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9803921569, alpha: 1) : #colorLiteral(red: 0.8971592784, green: 0.9046500325, blue: 0.9282500148, alpha: 1)
        label.textColor = selected == indexPath.row ? #colorLiteral(red: 0.6062102914, green: 0.6253217459, blue: 0.6361377239, alpha: 1): #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selected == indexPath.row {return}
        selected = indexPath.row
        collectionView.reloadData()
        switch indexPath.row {
        case 0:
            qrContainerView.isHidden = false
            loginPasswordContainerView.isHidden = true
        default:
            qrContainerView.isHidden = true
            loginPasswordContainerView.isHidden = false
        }
    }
}
