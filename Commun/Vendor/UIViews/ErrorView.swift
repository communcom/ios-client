//
//  ErrorView.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class ErrorView: MyView {

    lazy var imageView: UIImageView = {
        var imageView = UIImageView(forAutoLayout: ())
        imageView.image = UIImage(named: "no-connection-image")
        return imageView
    }()

    lazy var title: UILabel = {
        var label = UILabel(text: "no connection".localized().uppercaseFirst)
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    lazy var subtitle: UILabel = {
        var label = UILabel(text: "check your Internet connection\n and try again".localized().uppercaseFirst)
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor(hexString: "A5A7BD")
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    lazy var retryButton: UIButton = {
        var button = UIButton(width: 240, height: 50, label: "try again".localized().uppercaseFirst, labelFont: UIFont.systemFont(ofSize: 15, weight: .bold), backgroundColor: UIColor.appMainColor, textColor: .white, cornerRadius: 25, contentInsets: nil)
        return button
    }()

    var retryAction: (()->Void)?
    init(retryAction: (()->Void)?) {
        super.init(frame: .zero)
        self.retryAction = retryAction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white

        addSubview(imageView)
        imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 100)
        imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 45)
        imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 45)
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 285/350, constant: 0).isActive = true

        addSubview(title)
        title.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 20)
        title.autoPinEdge(toSuperviewEdge: .left)
        title.autoPinEdge(toSuperviewEdge: .right)

        addSubview(subtitle)
        subtitle.autoPinEdge(.top, to: .bottom, of: title, withOffset: 10)
        subtitle.autoPinEdge(toSuperviewEdge: .left)
        subtitle.autoPinEdge(toSuperviewEdge: .right)

        addSubview(retryButton)
        retryButton.autoPinEdge(.top, to: .bottom, of: subtitle, withOffset: 56, relation: .greaterThanOrEqual)
        retryButton.autoAlignAxis(toSuperviewAxis: .vertical)
        retryButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 110)
        retryButton.addTarget(self, action: #selector(retryDidTouch(_:)), for: .touchUpInside)
    }
    
    @objc func retryDidTouch(_ sender: UIButton) {
        retryAction?()
    }
}
