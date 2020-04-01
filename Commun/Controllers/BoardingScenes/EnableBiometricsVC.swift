//
//  EnableBiometricsVC.swift
//  Commun
//
//  Created by Chung Tran on 12/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import LocalAuthentication

class EnableBiometricsVC: BoardingVC {
    override var navigationBarType: BaseViewController.NavigationBarType {.hidden}
    
    override var step: CurrentUserSettingStep {.setFaceId}
    override var nextStep: CurrentUserSettingStep? {.ftue}
    
    lazy var imageView = UIImageView(width: 100, height: 100)
    lazy var headerLabel = UILabel.with(textSize: 17, weight: .bold, textAlignment: .center)
    lazy var descriptionLabel = UILabel.with(textSize: 17, textColor: .a5a7bd, numberOfLines: 2, textAlignment: .center)
    
    override func setUp() {
        super.setUp()
        AnalyticsManger.shared.registrationOpenScreen(6)
        // retrieve policy
        let biometryType = LABiometryType.current
        
        if #available(iOS 11.2, *) {
            if biometryType == .none {
                next()
                return
            }
        }
        
        // layout
        let containerView = UIView(forAutoLayout: ())
        view.addSubview(containerView)
        containerView.autoAlignAxis(.horizontal, toSameAxisOf: view, withOffset: -50)
        containerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 46)
        containerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 46)
        
        containerView.addSubview(imageView)
        imageView.autoPinEdge(toSuperviewEdge: .top)
        imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        containerView.addSubview(headerLabel)
        headerLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        headerLabel.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 32)
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: headerLabel, withOffset: 16)
        descriptionLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        imageView.image = biometryType.icon
        headerLabel.text = String(format: "%@ %@", "enable".localized().uppercaseFirst, biometryType.stringValue)
        descriptionLabel.text = String(format: "%@ %@ %@", "enable".localized().uppercaseFirst, biometryType.stringValue, "to secure your transactions".localized())
        
        // buttons
        let skipButton = UIButton(width: 290, height: 56, label: "skip".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), textColor: .appMainColor)
        view.addSubview(skipButton)
        skipButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 16)
        skipButton.autoAlignAxis(toSuperviewAxis: .vertical)
        skipButton.addTarget(self, action: #selector(skipButtonDidTouch(_:)), for: .touchUpInside)
        
        let enableButton = CommunButton.default(height: 56, label: String(format: "%@ %@", "enable".localized().uppercaseFirst, biometryType.stringValue), isHuggingContent: false)
        view.addSubview(enableButton)
        enableButton.autoAlignAxis(toSuperviewAxis: .vertical)
        enableButton.autoSetDimension(.width, toSize: 290)
        enableButton.autoPinEdge(.bottom, to: .top, of: skipButton, withOffset: -10)
        enableButton.addTarget(self, action: #selector(enableButtonDidTouch(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc func enableButtonDidTouch(_ sender: Any) {
        AnalyticsManger.shared.activateFaceID(true)
        UserDefaults.standard.set(true, forKey: Config.currentUserBiometryAuthEnabled)
        next()
    }
    
    @objc func skipButtonDidTouch(_ sender: Any) {
        AnalyticsManger.shared.activateFaceID(false)
        next()
    }
}
