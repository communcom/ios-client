//
//  CommunActionSheet.swift
//  Commun
//
//  Created by Chung Tran on 10/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class CommunActionSheet: SwipeDownDismissViewController {
    // MARK: - Nested types
    struct Action {
        var title: String
        var icon: UIImage?
        var handle: (() -> Void)?
    }
    class TapGesture: UITapGestureRecognizer {
        var action: Action?
    }
    
    // MARK: - Constants
    let defaultMargin: CGFloat = 16
    let buttonSize: CGFloat = 30
    var headerHeight: CGFloat = 40
    let headerToButtonsSpace: CGFloat = 30
    let actionViewHeight: CGFloat = 50
    let actionViewSeparatorSpace: CGFloat = 8
    
    // MARK: - Properties
    var backgroundColor = UIColor(hexString: "#F7F7F9")
    var actions: [Action]?
    
    var height: CGFloat {
        let actionsCount = actions?.count ?? 0
        
        let actionButtonsHeight = CGFloat(actionsCount) * (actionViewSeparatorSpace + actionViewHeight)
        
        return defaultMargin
            + headerHeight
            + headerToButtonsSpace
            + actionButtonsHeight
    }
    
    // MARK: - Subviews
    var headerView: UIView?
    lazy var closeButton: UIButton = {
        
        var button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "close-x"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.backgroundColor = .white
        button.tintColor = .lightGray
        button.cornerRadius = buttonSize / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: defaultMargin)
            .isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -defaultMargin)
            .isActive = true
        button.widthAnchor.constraint(equalToConstant: buttonSize)
            .isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonSize)
            .isActive = true
        button.addTarget(self, action: #selector(closeButtonDidTouch(_:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Swipe down
        interactor = SwipeDownInteractor()
        
        // Setup view
        view.backgroundColor = backgroundColor
        view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        
        // header view
        configHeaderView()
        
        // Setup actions
        addActions()
    }
    
    func configHeaderView() {
        // assign title
        if headerView == nil {
            headerView = UIView(frame: .zero)
            let titleLabel = UILabel(text: title ?? "options".localized().uppercaseFirst, style: .caption1)
            titleLabel.textAlignment = .center
            titleLabel.font = .boldSystemFont(ofSize: 20)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            headerView!.addSubview(titleLabel)
            
            titleLabel.topAnchor.constraint(equalTo: headerView!.topAnchor).isActive = true
            titleLabel.bottomAnchor.constraint(equalTo: headerView!.bottomAnchor).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: headerView!.trailingAnchor, constant: defaultMargin + buttonSize).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: headerView!.leadingAnchor).isActive = true
            
            headerHeight = 30
        }
        
        if let headerView = headerView {
            headerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(headerView)
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: defaultMargin).isActive = true
            headerView.heightAnchor.constraint(equalToConstant: headerHeight)
                .isActive = true
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: defaultMargin).isActive = true
            headerView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -defaultMargin).isActive = true
        }
    }
    
    func addActions() {
        guard let actions = actions else {return}
        for (index, action) in actions.enumerated() {
            // action views
            let actionView = UIView(frame: .zero)
            actionView.backgroundColor = .white
            actionView.cornerRadius = 10
            actionView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(actionView)
            
            
            actionView.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: defaultMargin + headerHeight + headerToButtonsSpace + CGFloat(index) * (actionViewSeparatorSpace + actionViewHeight)
            ).isActive = true
            actionView.heightAnchor.constraint(equalToConstant: actionViewHeight).isActive = true
            
            actionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: defaultMargin).isActive = true
            actionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -defaultMargin).isActive = true
            
            // icon
            let iconImageView = UIImageView(frame: .zero)
            iconImageView.tintColor = .black
            iconImageView.image = action.icon
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            actionView.addSubview(iconImageView)
            
            iconImageView.trailingAnchor.constraint(equalTo: actionView.trailingAnchor, constant: -defaultMargin).isActive = true
            iconImageView.centerYAnchor.constraint(equalTo: actionView.centerYAnchor).isActive = true
            iconImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
            iconImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
            
            // title
            let titleLabel = UILabel(frame: .zero)
            titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
            titleLabel.text = action.title
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            actionView.addSubview(titleLabel)
            
            titleLabel.leadingAnchor.constraint(equalTo: actionView.leadingAnchor, constant: defaultMargin).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: actionView.centerYAnchor).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: iconImageView.leadingAnchor, constant: -defaultMargin).isActive = true
            
            // handle action
            actionView.isUserInteractionEnabled = true
            let tap = TapGesture(target: self, action: #selector(actionViewDidTouch(_:)))
            tap.action = action
            actionView.addGestureRecognizer(tap)
        }
    }
    
    // MARK: - Actions
    @objc func closeButtonDidTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func actionViewDidTouch(_ tap: TapGesture) {
        guard let action = tap.action else {return}
        dismiss(animated: true) {
            action.handle?()
        }
    }
}


