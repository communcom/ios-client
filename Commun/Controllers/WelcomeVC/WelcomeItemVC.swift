//
//  WelcomeItemVC.swift
//  Commun
//
//  Created by Chung Tran on 3/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import Localize_Swift

class WelcomeItemVC: BaseViewController {
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.embeded}
    // MARK: - Constants
    let spacing: CGFloat = 16
    
    // MARK: - Properties
    let index: Int
    var imageViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var imageView = UIImageView(imageNamed: "image-welcome-item-\(index)", contentMode: .scaleAspectFit)
    lazy var titleLabel = UILabel.with(textSize: 36, numberOfLines: 0, textAlignment: .center)
    lazy var descriptionLabel = UILabel.with(textSize: 17, weight: .medium, textColor: .appGrayColor, numberOfLines: 0, textAlignment: .center)
    
    // MARK: - Initializers
    init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        view.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        view.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: spacing)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16, relation: .greaterThanOrEqual)
        titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16, relation: .greaterThanOrEqual)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.attributedText = getTitle(index: index)
        
        view.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: spacing)
        descriptionLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16, relation: .greaterThanOrEqual)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16, relation: .greaterThanOrEqual)
        descriptionLabel.setContentHuggingPriority(.required, for: .vertical)

        descriptionLabel.attributedText = getDescription(index: index)
        
        descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let titleHeight = titleLabel.intrinsicContentSize.height
        let descriptionHeight = descriptionLabel.intrinsicContentSize.height
        let height = view.height - titleHeight - descriptionHeight - 2 * spacing
        
        if let constraint = imageViewHeightConstraint {
            constraint.constant = height
            view.layoutIfNeeded()
        } else {
            imageViewHeightConstraint = imageView.autoSetDimension(.height, toSize: height)
        }
    }

    // MARK: - Texts
    private func getTitle(index: Int) -> NSAttributedString {
        let title: NSAttributedString
        switch Localize.currentLanguage() {
        case "ru-US", "ru-RU", "ru":
            switch index {
            case 1:
                title = NSMutableAttributedString()
                    .text("Весь контент", size: .adaptive(height: 36))
                    .text("\n")
                    .text("в ", size: .adaptive(height: 36))
                    .text("одном месте!", size: .adaptive(height: 36), weight: .bold)
            case 2:
                title = NSMutableAttributedString()
                    .text("Принадлежит пользователям", size: .adaptive(height: 36), weight: .bold)
            default:
                title = NSMutableAttributedString()
                    .text("Добро пожаловать", size: .adaptive(height: 36))
                    .text("\n")
                    .text("на", size: .adaptive(height: 36))
                    .text(" ")
                    .text("Commun /", size: .adaptive(height: 36), weight: .bold, color: .appMainColor)
            }
        default:
            switch index {
            case 1:
                title = NSMutableAttributedString()
                    .text("all-in-one".localized().uppercaseFirst, size: .adaptive(height: 36), weight: .bold)
                    .text("\n")
                    .text("social network".localized().uppercaseFirst, size: .adaptive(height: 36))
            case 2:
                title = NSMutableAttributedString()
                    .text("owned".localized().uppercaseFirst, size: .adaptive(height: 36), weight: .bold)
                    .text(" ", size: .adaptive(height: 36))
                    .text(String(format: "%@ %@", "by".localized().uppercaseFirst, "users".localized()), size: .adaptive(height: 36))

            default:
                title = NSMutableAttributedString()
                    .text("welcome".localized().uppercaseFirst, size: .adaptive(height: 36))
                    .text("\n")
                    .text("to".localized().uppercaseFirst, size: .adaptive(height: 36))
                    .text(" ")
                    .text("Commun /", size: .adaptive(height: 36), weight: .bold, color: .appMainColor)
            }
        }
        return title
    }

    private func getDescription(index: Int) -> NSAttributedString {
        let descriptionColor = UIColor.init(hexString: "#626371")!
        let description: NSAttributedString
        
        switch Locale.preferredLanguages.first {
        case "ru-US", "ru-RU", "ru":
            switch index {
            case 1:
                description = NSMutableAttributedString()
                    .semibold("Подписывайся на лучшие сообщества и зарабатывай награды", color: descriptionColor)
                    .text("\n")
                    .text(" ")
                    .withParagraphStyle(minimumLineHeight: 26, alignment: .center)
            case 2:
                description = NSMutableAttributedString()
                    .semibold("Благодоря блокчейну Commun полностью принадлежит и управляется пользователями", color: descriptionColor)
                    .withParagraphStyle(minimumLineHeight: 26, alignment: .center)
            default:
                description = NSMutableAttributedString()
                    .semibold("Социальную сеть на технологиях Блокчейн", color: descriptionColor)
                    .text("\n")
                    .semibold("Здесь вы", color: descriptionColor)
                    .text(" ")
                    .bold("зарабатываете награды", color: descriptionColor)
                    .semibold("за посты лайки и комментарии", color: descriptionColor)
                    .withParagraphStyle(minimumLineHeight: 26, alignment: .center)
            }
        default:
            switch index {
            case 1:
                description = NSMutableAttributedString()
                    .semibold("choose communities of interest and".localized().uppercaseFirst, color: descriptionColor)
                    .text("\n")
                    .semibold("be".localized().uppercaseFirst, color: descriptionColor)
                    .text(" ")
                    .bold("rewarded".localized(), color: .appMainColor)
                    .text(" ")
                    .semibold("for your actions".localized(), color: descriptionColor)
                    .text("\n")
                    .text(" ")
                    .withParagraphStyle(minimumLineHeight: 26, alignment: .center)
            case 2:
                description = NSMutableAttributedString()
                    .semibold("welcome-item-3".localized().uppercaseFirst, color: descriptionColor)
                    .withParagraphStyle(minimumLineHeight: 26, alignment: .center)

            default:
                description = NSMutableAttributedString()
                    .semibold("blockchain-based social network".localized().uppercaseFirst, color: descriptionColor)
                    .text("\n")
                    .semibold("where you get".localized(), color: descriptionColor)
                    .text(" ")
                    .bold("rewards".localized(), color: .appMainColor)
                    .text("\n")
                    .semibold("for posts, comments and likes".localized(), color: descriptionColor)
                    .withParagraphStyle(minimumLineHeight: 26, alignment: .center)
            }
        }

        return description
    }
}
