//
//  CommunActionSheet.swift
//  Commun
//
//  Created by Chung Tran on 10/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

class CommunActionSheet: SwipeDownDismissViewController {
    // MARK: - Nested types
    enum Style {
        case `default`
        case profile
        case follow
    }
    
    struct Action {
        var title: String
        var icon: UIImage?
        var style: Style = .default
        var tintColor: UIColor = .black
        var marginTop: CGFloat = 0
        var handle: (() -> Void)?

        class TapGesture: UITapGestureRecognizer {
            var action: Action?
        }
    }
    
    // MARK: - Constants
    var defaultMargin: CGFloat {
        switch style {
        case .default, .follow:
            return 16
        case .profile:
            return 10
        }
    }
    
    let buttonSize: CGFloat = 30
    var headerHeight: CGFloat = 40
    let headerToButtonsSpace: CGFloat = 23
    var actionViewHeight: CGFloat {
        switch style {
        case .default, .follow:
            return 50
        case .profile:
            return 65
        }
    }
    
    var actionViewSeparatorSpace: CGFloat {
        switch style {
        case .default, .follow:
            return 8
        case .profile:
            return 2
        }
    }
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: .adaptive(width: 24.0), height: .adaptive(height: 24.0))))
        activity.hidesWhenStopped = true
        activity.style = .white
        activity.color = .black
        activity.translatesAutoresizingMaskIntoConstraints = false
        
        return activity
    }()

    
    // MARK: - Properties
    var style: Style
    var backgroundColor = UIColor(hexString: "#F7F7F9")
    var actions: [Action]?

    var titleFont: UIFont = .boldSystemFont(ofSize: 20)
    var textAlignment: NSTextAlignment = .center

    var height: CGFloat {
        let actionsCount = actions?.count ?? 0
        
        let actionButtonsHeight = CGFloat(actionsCount) * (actionViewSeparatorSpace + actionViewHeight)
        
        return defaultMargin
            + headerHeight
            + headerToButtonsSpace
            + actionButtonsHeight
            + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
    }
    
    // MARK: - Subviews
    var headerView: UIView?
    
    lazy var closeButton: UIButton = {
        var button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "close-x"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(inset: 3)
        button.backgroundColor = .white
        button.tintColor = .a5a7bd
        button.cornerRadius = buttonSize / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
            .isActive = true
        button.widthAnchor.constraint(equalToConstant: buttonSize)
            .isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonSize)
            .isActive = true

        button.touchAreaEdgeInsets = UIEdgeInsets(inset: -7)
        button.addTarget(self, action: #selector(closeButtonDidTouch(_:)), for: .touchUpInside)

        return button
    }()
    
    // MARK: - Initializer
    init(style: Style = .default) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
            titleLabel.textAlignment = textAlignment
            titleLabel.font = titleFont
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            headerView!.addSubview(titleLabel)

            titleLabel.autoPinEdge(toSuperviewEdge: .left)
            titleLabel.autoPinEdge(toSuperviewEdge: .right)
            titleLabel.topAnchor.constraint(equalTo: headerView!.topAnchor).isActive = true
            titleLabel.bottomAnchor.constraint(equalTo: headerView!.bottomAnchor).isActive = true
            
            headerHeight = 30
        }
        
        if let headerView = headerView {
            headerView.configureForAutoLayout()
            view.addSubview(headerView)
            headerView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
            headerView.autoSetDimension(.height, toSize: headerHeight)
            headerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            headerView.autoPinEdge(.trailing, to: .leading, of: closeButton)
            headerView.autoAlignAxis(.horizontal, toSameAxisOf: closeButton)
        }
    }
    
    func addActions() {
        guard let actions = actions else {return}
        
        for (index, action) in actions.enumerated() {
            // action views
            let actionView = UIView(backgroundColor: .white, cornerRadius: 10)
            
            view.addSubview(actionView)
            
            let topInset: CGFloat = defaultMargin + headerHeight + headerToButtonsSpace + CGFloat(index) * (actionViewSeparatorSpace + actionViewHeight) + action.marginTop
            
            actionView.autoPinEdge(toSuperviewEdge: .top, withInset: topInset)
            actionView.autoSetDimension(.height, toSize: actionViewHeight)
            actionView.autoPinEdge(toSuperviewEdge: .leading, withInset: defaultMargin)
            actionView.autoPinEdge(toSuperviewEdge: .trailing, withInset: defaultMargin)
            
            // icon
            let iconImageView = UIImageView(forAutoLayout: ())
           
            if style == .default || style == .follow {
                iconImageView.tintColor = action.tintColor
            }
            
            iconImageView.image = action.icon
            actionView.addSubview(iconImageView)
            
            switch style {
            case .default, .follow:
                iconImageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: defaultMargin)
                iconImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
                iconImageView.autoSetDimensions(to: CGSize(width: 24, height: 24))
            
            case .profile:
                iconImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
                iconImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
                iconImageView.autoSetDimensions(to: CGSize(width: 35, height: 35))
            }
            
            // title
            let titleLabel = UILabel.with(text: action.title, textSize: 15, weight: .medium, textColor: action.tintColor)
            
            actionView.addSubview(titleLabel)
            
            switch style {
            case .default, .follow:
                titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: defaultMargin)
                titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
                titleLabel.autoPinEdge(.trailing, to: .leading, of: iconImageView, withOffset: -defaultMargin)
                
                if action.style == .follow {
                    titleLabel.tag = 777
                    iconImageView.tag = 778
                }
            
            case .profile:
                titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
                titleLabel.autoPinEdge(.leading, to: .trailing, of: iconImageView, withOffset: 10)
                titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
            }
            
            // arrow image for style profile
            if action.style == .profile {
                let nextButton = UIButton.circleGray(imageName: "cell-arrow", imageEdgeInsets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
                nextButton.isUserInteractionEnabled = false
                actionView.addSubview(nextButton)
                nextButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
                nextButton.autoAlignAxis(toSuperviewAxis: .horizontal)
                nextButton.autoPinEdge(.leading, to: .trailing, of: titleLabel, withOffset: 10)
            }
            
            // handle action
            actionView.isUserInteractionEnabled = true
            let tap = Action.TapGesture(target: self, action: #selector(actionViewDidTouch(_:)))
            tap.action = action
            actionView.addGestureRecognizer(tap)
        }
    }
    
    func updateAction(byIndex index: Int, withProperties properties: (title: String, icon: UIImage), handle: @escaping (() -> Void)) {
        guard var actions = self.actions, let label = view.viewWithTag(777) as? UILabel, let iconImageView = view.viewWithTag(778) as? UIImageView else { return }
        
        actions[index].title = properties.title
        actions[index].icon = properties.icon
        label.text = properties.title
        iconImageView.setImage(properties.icon)
        
        handle()
    }
    
    func loaderDidStart(byIndex index: Int) {
        guard let actions = self.actions, let iconImageView = view.viewWithTag(778) as? UIImageView else { return }
        
        iconImageView.image = nil
        iconImageView.addSubview(activityIndicator)
        activityIndicator.autoPinEdgesToSuperviewEdges()
        activityIndicator.startAnimating()
    }
    
    func loaderDidFinish() {
        activityIndicator.stopAnimating()
    }
    
    
    // MARK: - Actions
    @objc func closeButtonDidTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func actionViewDidTouch(_ tap: Action.TapGesture) {
        guard let action = tap.action else { return }
        guard action.style != .follow else { action.handle?(); return }
        
        dismiss(animated: true) {
            action.handle?()
        }
    }
}
