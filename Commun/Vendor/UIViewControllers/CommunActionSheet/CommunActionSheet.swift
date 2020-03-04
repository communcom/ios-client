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
        
        var defaultMargin: CGFloat {
            switch self {
            case .default, .follow:
                return 16
            case .profile:
                return 10
            }
        }
        
        var actionViewHeight: CGFloat {
            switch self {
            case .default, .follow:
                return 50
            case .profile:
                return 65
            }
        }
        
        var actionViewSeparatorSpace: CGFloat {
            switch self {
            case .default, .follow:
                return 8
            case .profile:
                return 2
            }
        }
    }
    
    struct Action {
        var title: String
        var icon: UIImage?
        var style: Style = .default
        var tintColor: UIColor = .black
        var marginTop: CGFloat = 0
        var post: ResponseAPIContentGetPost?
        var handle: (() -> Void)?

        class TapGesture: UITapGestureRecognizer {
            var action: Action?
        }
    }
    
    // MARK: - Constants
    let buttonSize: CGFloat = 30
    var headerHeight: CGFloat = 40
    let headerToButtonsSpace: CGFloat = 23
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: .adaptive(width: 24.0), height: .adaptive(height: 24.0))))
        activity.hidesWhenStopped = false
        activity.style = .white
        activity.color = .black
        activity.translatesAutoresizingMaskIntoConstraints = false
        
        return activity
    }()

    // MARK: - Properties
    var backgroundColor = UIColor(hexString: "#F7F7F9")
    var actions: [Action]?

    var titleFont: UIFont = .boldSystemFont(ofSize: 20)
    var textAlignment: NSTextAlignment = .center

    var height: CGFloat {
        guard let actions = actions, actions.count > 0 else {return 0}
        
        let buttonsHeight = actions.reduce(0) { (result, action) -> CGFloat in
            result + action.style.actionViewSeparatorSpace + action.style.actionViewHeight
        }
        
        return actions.first!.style.defaultMargin
            + headerHeight
            + headerToButtonsSpace
            + buttonsHeight
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
    init() {
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
            
            let topInset: CGFloat = action.style.defaultMargin + headerHeight + headerToButtonsSpace + CGFloat(index) * (action.style.actionViewSeparatorSpace + action.style.actionViewHeight) + action.marginTop
            
            actionView.autoPinEdge(toSuperviewEdge: .top, withInset: topInset)
            actionView.autoSetDimension(.height, toSize: action.style.actionViewHeight)
            actionView.autoPinEdge(toSuperviewEdge: .leading, withInset: action.style.defaultMargin)
            actionView.autoPinEdge(toSuperviewEdge: .trailing, withInset: action.style.defaultMargin)
            
            // icon
            let iconImageView = UIImageView(forAutoLayout: ())
           
            if action.style == .default || action.style == .follow {
                iconImageView.tintColor = action.tintColor
            }
            
            iconImageView.image = action.icon
            actionView.addSubview(iconImageView)
            
            switch action.style {
            case .default, .follow:
                iconImageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: action.style.defaultMargin)
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
            
            switch action.style {
            case .default, .follow:
                titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: action.style.defaultMargin)
                titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
                titleLabel.autoPinEdge(.trailing, to: .leading, of: iconImageView, withOffset: -action.style.defaultMargin)
                
                if action.style == .follow {
                    titleLabel.tag = 777
                    iconImageView.tag = 778
                }
            
            case .profile:
                titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
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
    
    func loaderDidStart(withTitle title: String) {
        guard let label = view.viewWithTag(777) as? UILabel, let iconImageView = view.viewWithTag(778) as? UIImageView else { return }

        DispatchQueue.main.async {
                    label.text = title
            iconImageView.image = nil
            iconImageView.addSubview(self.activityIndicator)
            self.activityIndicator.autoPinEdgesToSuperviewEdges()
            self.activityIndicator.startAnimating()
        }
    }
    
    private func loaderDidFinish() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    func setupAction(isSubscribed: Bool) -> (title: String, icon: UIImage) {
        return (title: (isSubscribed ? "following" : "follow").localized().uppercaseFirst, icon: UIImage(named: isSubscribed ? "icon-following-black-cyrcle-default" : "icon-follow-black-plus-default")!)
    }
    
    func updateFollowAction(withCommunity community: ResponseAPIContentGetCommunity) {
        let actionProperties = setupAction(isSubscribed: community.isSubscribed ?? false)

        var communityTemp = community
        communityTemp.isBeingJoined = true
        actions?[0].post?.community = community
                
        updateFollowAction(image: actionProperties.icon)
        communityTemp.isBeingJoined = false
        loaderDidFinish()
    }

    private func updateFollowAction(image: UIImage) {
        guard let iconImageView = view.viewWithTag(778) as? UIImageView else { return }

        iconImageView.setImage(image)
    }
    
    
    // MARK: - Actions
    @objc func closeButtonDidTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func actionViewDidTouch(_ tap: Action.TapGesture) {
        guard let action = tap.action else { return }
        
        guard action.style != .follow else {
            if !activityIndicator.isAnimating {
                action.handle?()
            }
            
            return
        }
        
        dismiss(animated: true) {
            action.handle?()
        }
    }
}
