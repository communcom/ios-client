//
//  ErrorView.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class ErrorView: MyView {
    var imageRatio: CGFloat
    
    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "no-connection-image")
        return imageView
    }()

    lazy var title: UILabel = {
        var label = UILabel(text: "no connection".localized().uppercaseFirst)
        label.font = UIFont.systemFont(ofSize: CGFloat.adaptive(width: 30), weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    lazy var subtitle: UILabel = {
        var label = UILabel(text: "check your Internet connection\n and try again".localized().uppercaseFirst)
        label.font = UIFont.systemFont(ofSize: CGFloat.adaptive(width: 17), weight: .medium)
        label.textColor = UIColor(hexString: "A5A7BD")
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    lazy var retryButton: UIButton = {
        var button = UIButton(height: 50 * Config.heightRatio, label: "try again".localized().uppercaseFirst, labelFont: UIFont.systemFont(ofSize: 15, weight: .bold), backgroundColor: UIColor.appMainColor, textColor: .white, cornerRadius: 25 * Config.heightRatio)
        return button
    }()

    var retryAction: (()->Void)?
    init(
        imageRatio: CGFloat = 285/350,
        imageNamed: String = "no-connection-image",
        title: String = "no connection".localized().uppercaseFirst,
        subtitle: String = "check your Internet connection\n and try again".localized().uppercaseFirst,
        retryButtonTitle: String = "try again".localized().uppercaseFirst,
        retryAction: (()->Void)?
    ) {
        self.imageRatio = imageRatio
        super.init(frame: .zero)
        self.imageView.image = UIImage(named: imageNamed)
        self.title.text = title
        self.subtitle.text = subtitle
        self.retryButton.setTitle(retryButtonTitle, for: .normal)
        self.retryAction = retryAction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white

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
        imageView.autoPinEdge(toSuperviewSafeArea: .top, withInset: 10 * Config.heightRatio)
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
        retryButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 16 * Config.heightRatio)
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
