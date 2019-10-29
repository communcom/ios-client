//
//  MyProfilePageVC.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class MyProfilePageVC: UserProfilePageVC {
    // MARK: - Subviews
    
    lazy var changeCoverButton: UIButton = {
        let button = UIButton(width: 24, height: 24, backgroundColor: UIColor.black.withAlphaComponent(0.3), cornerRadius: 12, contentInsets: UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))
        button.tintColor = .white
        button.setImage(UIImage(named: "photo_solid")!, for: .normal)
        return button
    }()
    
    // MARK: - Initializers
    init() {
        super.init(userId: Config.currentUser?.id ?? "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        
        view.addSubview(changeCoverButton)
        changeCoverButton.autoPinEdge(.bottom, to: .bottom, of: coverImageView, withOffset: -40)
        changeCoverButton.autoPinEdge(.trailing, to: .trailing, of: coverImageView, withOffset: -16)
    }
    
    override func bind() {
        super.bind()
        tableView.rx.contentOffset
            .map {$0.y}
            .map {$0 < -140}
            .subscribe(onNext: { show in
                self.changeCoverButton.isHidden = !show
            })
            .disposed(by: disposeBag)
    }
    
    override func setHeaderView() {
        headerView = MyProfileHeaderView(tableView: tableView)
    }
    
    override func showTitle(_ show: Bool, animated: Bool = false) {
        // disable effect
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
