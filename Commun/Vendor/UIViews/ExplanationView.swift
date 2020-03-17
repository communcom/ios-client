//
//  ExplanationView.swift
//  Commun
//
//  Created by Chung Tran on 3/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ExplanationView: MyView {
    // MARK: - Properties
    var title: String
    var descriptionText: String
    var imageName: String?
    
    // MARK: - Subviews
    lazy var titleLabel = UILabel.with(text: title, textSize: 14, weight: .semibold, textColor: .white, numberOfLines: 0)
    lazy var closeButton = UIButton.close(backgroundColor: .clear, tintColor: .white)
    
    lazy var descriptionLabel = UILabel.with(text: descriptionText, textSize: 12, textColor: .white, numberOfLines: 0)
    
    lazy var imageView = UIImageView(width: 100, height: 100, imageNamed: imageName)
    lazy var dontShowAgainButton = UIButton(label: "don't show this again".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 12, weight: .medium), textColor: .white)
    lazy var learnMoreButton = UIButton(label: "learn more".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 12, weight: .medium), textColor: .white)
    
    // MARK: - Initializers
    init(title: String, descriptionText: String, imageName: String? = nil) {
        self.title = title
        self.descriptionText = descriptionText
        self.imageName = imageName
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        let hStack: UIStackView = {
            let hStack = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
            
            if self.imageName != nil {
                hStack.addArrangedSubview(self.imageView)
            }
            
            var vStack: UIStackView {
                let vStack = UIStackView(axis: .vertical, spacing: 20, alignment: .leading, distribution: .fill)
                
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
        
        addSubview(hStack)
        hStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 10))
        
        backgroundColor = .appMainColor
        cornerRadius = 6
        
        closeButton.addTarget(self, action: #selector(buttonCloseDidTouch), for: .touchUpInside)
    }
    
    @objc func buttonCloseDidTouch() {
        removeFromSuperview()
    }
}
