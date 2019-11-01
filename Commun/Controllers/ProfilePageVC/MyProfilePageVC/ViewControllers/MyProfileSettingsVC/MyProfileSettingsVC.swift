//
//  MyProfileSettingsVC.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class MyProfileSettingsVC: BaseViewController {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // MARK: - Subviews
    lazy var backButton = UIButton.back(tintColor: .black, contentInsets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 24))
    lazy var scrollView = ContentHuggingScrollView(forAutoLayout: ())
    override var contentScrollView: UIScrollView? {
        return scrollView
    }
    var stackView: UIStackView!
    
    lazy var userView: UIView = {
        let view = UIView(height: 80, backgroundColor: .white, cornerRadius: 10)
        
        let avatarImage = MyAvatarImageView(size: 50)
        avatarImage.setToCurrentUserAvatar()
        view.addSubview(avatarImage)
        avatarImage.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        avatarImage.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        let userLabel = UILabel.with(text: Config.currentUser?.name, textSize: 20, weight: .bold)
        view.addSubview(userLabel)
        userLabel.autoPinEdge(.top, to: .top, of: avatarImage, withOffset: 4)
        userLabel.autoPinEdge(.leading, to: .trailing, of: avatarImage, withOffset: 10)
        
        let userIdLabel = UILabel.with(text: "@" + (Config.currentUser?.id ?? ""), textSize: 12, textColor: .appMainColor)
        view.addSubview(userIdLabel)
        userIdLabel.autoPinEdge(.top, to: .bottom, of: userLabel, withOffset: 3)
        userIdLabel.autoPinEdge(.leading, to: .trailing, of: avatarImage, withOffset: 10)
        
        let button = UIButton.circleGray(imageName: "next-arrow")
        button.isUserInteractionEnabled = false
        view.addSubview(button)
        button.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        button.autoAlignAxis(toSuperviewAxis: .horizontal)
        button.autoPinEdge(.leading, to: .trailing, of: userLabel, withOffset: 10)
        
        return view
    }()
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .f3f5fa
        title = "settings".localized().uppercaseFirst
        
        // backButton
        setLeftNavBarButton(with: backButton)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        // navigationBar style
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.setTitleFont(.boldSystemFont(ofSize: 17), color:
            .black)
        
        // scrollView
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()
        
        scrollView.contentView.addSubview(userView)
        userView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10), excludingEdge: .bottom)
        
        // add actions
        stackView = stackViewWithActions(actions: [
            CommunActionSheet.Action(title: "notifications".localized().uppercaseFirst, icon: UIImage(named: "profile_options_notifications"), handle: {
                self.showNotificationSettings()
            }),
//            CommunActionSheet.Action(title: "interface language".localized().uppercaseFirst, icon: UIImage(named: "profile_options_interface_language"), handle: {
//                self.selectLanguage()
//            }),
            CommunActionSheet.Action(title: "password".localized().uppercaseFirst, icon: UIImage(named: "profile_options_password"), handle: {
                
            })
        ])
        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        stackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        stackView.autoPinEdge(.top, to: .bottom, of: userView, withOffset: 20)
        
        let logoutButton = UIButton(height: 65, label: "log out".localized().uppercaseFirst, backgroundColor: .white, textColor: UIColor(hexString: "#ED2C5B")!, cornerRadius: 10)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        
        scrollView.contentView.addSubview(logoutButton)
        logoutButton.autoPinEdge(.top, to: .bottom, of: stackView, withOffset: 20)
        
        
        logoutButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 10), excludingEdge: .top)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.arrangedSubviews.first?.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 10)
        stackView.arrangedSubviews.last?.roundCorners(UIRectCorner(arrayLiteral: .bottomLeft, .bottomRight), radius: 10)
    }
    
    func stackViewWithActions(actions: [CommunActionSheet.Action]) -> UIStackView {
        let stackView = UIStackView(axis: .vertical, spacing: 2)
        for action in actions {
            let actionView = UIView(height: 65, backgroundColor: .white)
            actionView.isUserInteractionEnabled = true
            let tap = CommunActionSheet.Action.TapGesture(target: self, action: #selector(actionViewDidTouch(_:)))
            tap.action = action
            actionView.addGestureRecognizer(tap)
            
            let imageView = UIImageView(width: 35, height: 35)
            imageView.image = action.icon
            actionView.addSubview(imageView)
            imageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            let label = UILabel.with(text: action.title, textSize: 17)
            actionView.addSubview(label)
            label.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 10)
            label.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            let button = UIButton.circleGray(imageName: "next-arrow")
            button.isUserInteractionEnabled = false
            actionView.addSubview(button)
            button.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
            button.autoAlignAxis(toSuperviewAxis: .horizontal)
            button.autoPinEdge(.leading, to: .trailing, of: label, withOffset: 10)
            
            stackView.addArrangedSubview(actionView)
            actionView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
                .isActive = true
        }
        return stackView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
