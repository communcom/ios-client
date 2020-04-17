//
//  ExplanationView.swift
//  Commun
//
//  Created by Chung Tran on 3/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ExplanationView: MyView {
    // MARK: - Static functions
    static func userDefaultKeyForId(_ id: String) -> String {
        "ExplanationView.\(id).showed"
    }
    
    static func shouldShowViewWithId(_ id: String) -> Bool {
        !UserDefaults.standard.bool(forKey: userDefaultKeyForId(id))
    }
    
    static func markAsShown(_ id: String) {
        UserDefaults.standard.set(true, forKey: userDefaultKeyForId(id))
    }
    
    // MARK: - Properties
    let id: String
    var title: String
    var descriptionText: String
    var imageName: String?
    var senderView: UIView
    var showAbove: Bool
    let learnMoreLink: String
    
    var shouldShow: Bool {
        ExplanationView.shouldShowViewWithId(id)
    }
    
    var closeDidTouch: (() -> Void)?
    
    // MARK: - Subviews
    lazy var containerView = UIView(backgroundColor: .appMainColor)
    lazy var titleLabel = UILabel.with(text: title, textSize: 14, weight: .semibold, textColor: .appWhiteColor, numberOfLines: 0)
    lazy var closeButton = UIButton.close(backgroundColor: .clear, tintColor: .appWhiteColor)
    
    lazy var descriptionLabel = UILabel.with(text: descriptionText, textSize: 12, textColor: .appWhiteColor, numberOfLines: 0)
    
    lazy var imageView = UIImageView(width: .adaptive(width: 100), height: .adaptive(width: 100), imageNamed: imageName, contentMode: .scaleAspectFit)
    lazy var dontShowAgainButton = UIButton(label: "don't show this again".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 12, weight: .semibold), textColor: .appWhiteColor)
    lazy var learnMoreButton = UIButton(label: "learn more".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 12, weight: .semibold), textColor: .appWhiteColor)
    lazy var arrowView = UIView(width: 10, height: 10, backgroundColor: .appMainColor, cornerRadius: 2)
    
    // MARK: - Initializers
    init(id: String, title: String, descriptionText: String, imageName: String? = nil, senderView: UIView, showAbove: Bool, learnMoreLink: String = "https://commun.com/faq") {
        self.id = id
        self.title = title
        self.descriptionText = descriptionText
        self.imageName = imageName
        self.senderView = senderView
        self.showAbove = showAbove
        self.learnMoreLink = learnMoreLink
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        let hStack: UIStackView = {
            let hStack = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
            
            if self.imageName != nil {
                hStack.addArrangedSubview(self.imageView)
            }
            
            var vStack: UIStackView {
                let vStack = UIStackView(axis: .vertical, spacing: .adaptive(width: 20), alignment: .leading, distribution: .fill)
                
                let hStack: UIStackView = {
                    let hStack = UIStackView(axis: .horizontal, alignment: .top, distribution: .fill)
                    hStack.addArrangedSubviews([self.titleLabel, self.closeButton])
                    return hStack
                }()
                vStack.addArrangedSubview(hStack)
                hStack.widthAnchor.constraint(equalTo: vStack.widthAnchor).isActive = true
                
                vStack.addArrangedSubview(self.descriptionLabel)
                
                let hStack2: UIStackView = {
                    let hStack = UIStackView(axis: .horizontal, distribution: .equalSpacing)
                    hStack.addArrangedSubviews([self.dontShowAgainButton, self.learnMoreButton])
                    return hStack
                }()
                vStack.addArrangedSubview(hStack2)
                hStack2.widthAnchor.constraint(equalTo: vStack.widthAnchor).isActive = true
                
                return vStack
            }
            hStack.addArrangedSubview(vStack)
            return hStack
        }()
        
        containerView.addSubview(hStack)
        hStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 16))
        
        containerView.cornerRadius = 6
        
        addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: showAbove ? .bottom : .top)
        containerView.autoPinEdge(toSuperviewEdge: showAbove ? .bottom : .top, withInset: 10)
    
        arrowView.transform = arrowView.transform.rotated(by: 45 / 180.0 * CGFloat.pi)
        addSubview(arrowView)
        arrowView.autoPinEdge(showAbove ? .bottom : .top, to: showAbove ? .bottom : .top, of: containerView, withOffset: showAbove ? 5 : -5)
        
        closeButton.addTarget(self, action: #selector(buttonCloseDidTouch), for: .touchUpInside)
        learnMoreButton.addTarget(self, action: #selector(buttonLearnMoreDidTouch), for: .touchUpInside)
        dontShowAgainButton.addTarget(self, action: #selector(buttonDontShowAgainDidTouch), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.addShadow(ofColor: .appBlackColor, radius: 10, offset: .zero, opacity: 0.25)
    }
    
    func fixArrowView() {
        arrowView.autoAlignAxis(.vertical, toSameAxisOf: senderView)
    }
    
    @objc func buttonCloseDidTouch() {
        if closeDidTouch == nil {
            removeFromSuperview()
        } else {
            closeDidTouch?()
        }
    }
    
    @objc func buttonDontShowAgainDidTouch() {
        ExplanationView.markAsShown(id)
        if closeDidTouch == nil {
            removeFromSuperview()
        } else {
            closeDidTouch?()
        }
    }
    
    @objc func buttonLearnMoreDidTouch() {
        (parentViewController as? BaseViewController)?.load(url: learnMoreLink)
    }
}
