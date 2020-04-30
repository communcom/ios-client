//
//  ErrorView.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class ErrorView: MyView {
    var imageRatio: CGFloat
    
    lazy var imageView = UIImageView(forAutoLayout: ())
    
    lazy var title = UILabel.with(textSize: .adaptive(height: 30), weight: .semibold, textColor: .appBlackColor, numberOfLines: 0, textAlignment: .center)

    lazy var subtitle = UILabel.with(textSize: .adaptive(height: 17), weight: .medium, textColor: .appGrayColor, numberOfLines: 0, textAlignment: .center)
    
    lazy var retryButton = UIButton(height: .adaptive(height: 50), labelFont: UIFont.systemFont(ofSize: 15, weight: .bold), backgroundColor: .appMainColor, textColor: .white, cornerRadius: .adaptive(height: 25))

    var retryAction: (() -> Void)?
    
    init(
        imageRatio: CGFloat? = nil,
        imageNamed: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        retryButtonTitle: String? = nil,
        retryAction: (() -> Void)? = nil
    ) {
        self.imageRatio = imageRatio ?? 285/350
        super.init(frame: .zero)
        self.imageView.image = UIImage(named: imageNamed ?? "no-connection-image")
        self.title.text = title ?? "no connection".localized().uppercaseFirst
        self.subtitle.text = subtitle ?? "check your Internet connection".localized().uppercaseFirst
        self.retryButton.setTitle(retryButtonTitle ?? "try again".localized().uppercaseFirst, for: .normal)
        self.retryAction = retryAction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .appWhiteColor

        addSubview(imageView)
        layoutImageView()
        
        addSubview(title)
        layoutTitle()

        addSubview(subtitle)
        layoutSubtitle()

        addSubview(retryButton)
        layoutButton()
        retryButton.addTarget(self, action: #selector(retryDidTouch(_:)), for: .touchUpInside)
    }
    
    func layoutImageView() {
        imageView.autoPinEdge(toSuperviewSafeArea: .top, withInset: 50 * Config.heightRatio)
        imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageRatio)
            .isActive = true
    }
    
    func layoutTitle() {
        title.textAlignment = .center
        title.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 10 * Config.heightRatio)
        title.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        title.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
    
    func layoutSubtitle() {
        subtitle.autoPinEdge(.top, to: .bottom, of: title, withOffset: 16 * Config.heightRatio)
        subtitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        subtitle.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
    
    func layoutButton() {
        retryButton.autoPinEdge(.top, to: .bottom, of: subtitle, withOffset: 40 * Config.heightRatio)
        retryButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 30 * Config.heightRatio)
        retryButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 30 * Config.heightRatio)
        retryButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 50 * Config.heightRatio + 45)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let titleHeight = title.intrinsicContentSize.height
        title.autoSetDimension(.height, toSize: titleHeight)
        let subtitleHeight = subtitle.intrinsicContentSize.height
        subtitle.autoSetDimension(.height, toSize: subtitleHeight)
    }
    
    @objc func retryDidTouch(_ sender: UIButton) {
        retryAction?()
    }
}
