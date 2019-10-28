//
//  ProfileVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension ProfileVC {
    @objc func bindControls() {
        // headerView parallax
        tableView.rx.contentOffset
            .map {$0.y}
            .subscribe(onNext: {offsetY in
                self.updateHeaderView()
            })
            .disposed(by: disposeBag)
        
        // scrolling
        tableView.rx.didScroll
            .map {_ in self.tableView.contentOffset.y < -43}
            .distinctUntilChanged()
            .subscribe(onNext: { showNavBar in
                self.navigationBar.backButton.tintColor = !showNavBar ? .black: .white
                self.navigationBar.titleLabel.textColor = !showNavBar ? .black: .clear
                self.navigationBar.backgroundColor = !showNavBar ? .white: .clear
            })
            .disposed(by: disposeBag)
    }
    
    private func updateHeaderView() {
        let offset = tableView.contentOffset.y
        if offset < -coverHeight {
            let originHeight = coverHeight
            
            let scale = -offset / (originHeight  - 24)
            coverImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        } else {
            coverImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        coverImageView.layoutIfNeeded()
    }
}
