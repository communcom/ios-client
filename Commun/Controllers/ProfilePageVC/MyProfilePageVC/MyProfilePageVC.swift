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
    lazy var optionsButton = UIButton.option(tintColor: .white)
    
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
        // hide back button
        navigationItem.leftBarButtonItem = nil
        
        // add optionsbutton
        let rightButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 40))
        rightButtonView.addSubview(optionsButton)
        optionsButton.autoPinEdgesToSuperviewEdges()
        optionsButton.addTarget(self, action: #selector(moreActionsButtonDidTouch(_:)), for: .touchUpInside)
        rightButtonView.addSubview(optionsButton)

        let rightBarButton = UIBarButtonItem(customView: rightButtonView)
        navigationItem.rightBarButtonItem = rightBarButton
        
        // layout subview
        view.addSubview(changeCoverButton)
        changeCoverButton.autoPinEdge(.bottom, to: .bottom, of: coverImageView, withOffset: -60)
        changeCoverButton.autoPinEdge(.trailing, to: .trailing, of: coverImageView, withOffset: -16)
        
        changeCoverButton.addTarget(self, action: #selector(changeCoverBtnDidTouch(_:)), for: .touchUpInside)
    }
    
    override func bind() {
        super.bind()
        let offSetY = tableView.rx.contentOffset
            .map {$0.y}.share()
            
        offSetY
            .map {$0 < -140}
            .subscribe(onNext: { show in
                self.changeCoverButton.isHidden = !show
            })
            .disposed(by: disposeBag)
        
        offSetY
            .map {$0 < -43}
            .subscribe(onNext: { showNavBar in
                self.optionsButton.tintColor = !showNavBar ? .black : .white
            })
            .disposed(by: disposeBag)
    }
    
    override func setHeaderView() {
        headerView = MyProfileHeaderView(tableView: tableView)
        
        let myHeader = headerView as! MyProfileHeaderView
        myHeader.changeAvatarButton.addTarget(self, action: #selector(changeAvatarBtnDidTouch(_:)), for: .touchUpInside)
        myHeader.addBioButton.addTarget(self, action: #selector(addBioButtonDidTouch(_:)), for: .touchUpInside)
        myHeader.descriptionLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(bioLabelDidTouch(_:)))
        myHeader.descriptionLabel.addGestureRecognizer(tap)
    }
}
