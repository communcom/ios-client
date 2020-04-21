//
//  CMHint.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 19.02.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import UIKit

class CMHint: UIView {
    // MARK: - Properties
    enum HintType {
        case enterText
        case enterAmount
        case enterTextPhoto
        case enterDifferentText
        
        case chooseFriend
        case chooseProblem
        case chooseCommunity
        
        case error(String)
        
        func introduced() -> String {
            switch self {
            case .enterText:
                return "hint type enter text".localized().uppercaseFirst

            case .enterAmount:
                return "hint type enter amount".localized().uppercaseFirst

            case .enterTextPhoto:
                return "hint type enter text or photo".localized().uppercaseFirst
                
            case .enterDifferentText:
                return "hint type enter different text".localized().uppercaseFirst
            
            case .chooseFriend:
                return "hint type choose friend".localized().uppercaseFirst
           
            case .chooseProblem:
                return "hint type choose problem".localized().uppercaseFirst
            
            case .chooseCommunity:
                return "hint type choose community".localized().uppercaseFirst
            
            case .error(let text):
                return text.replacingOccurrences(of: "Error: ", with: "").localized().uppercaseFirst
            }
        }
    }
    
    var type: HintType
    private var tabbarHeight: CGFloat = 0.0
    
    var topicLabel = UILabel(text: "warning".localized().uppercaseFirst,
                             font: .systemFont(ofSize: 15.0, weight: .bold),
                             numberOfLines: 0,
                             color: .appLightGrayColor)

    lazy var contentLabel: UILabel = {
        let contentLabelInstance = UILabel(text: "",
                                           font: .systemFont(ofSize: 12.0, weight: .medium),
                                           numberOfLines: 0,
                                           color: .appLightGrayColor)
        contentLabelInstance.alpha = 0.6
        
        return contentLabelInstance
    }()
    
    // MARK: - Class Initialization
    init(type: HintType, isTabbarHidden: Bool) {
        self.type = type
        self.tabbarHeight = CGFloat((!isTabbarHidden).int) * tabBarHeight
        
        super.init(frame: CGRect(origin: CGPoint(x: 15.0, y: DeviceScreen.ScreenSize.height + 100.0), size: CGSize(width: 345.0, height: 64.0)))

        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom Functions
    func commonInit() {
        alpha = 0.0
        backgroundColor = .appBlackColor
        layer.cornerRadius = 10.0
        
        let labelsStackView = UIStackView(arrangedSubviews: [topicLabel, contentLabel],
                                          axis: .vertical,
                                          spacing: 2.0,
                                          alignment: .fill,
                                          distribution: .fillProportionally)
        
        let imageView = UIImageView(width: 30.0,
                                    height: 30.0,
                                    cornerRadius: 30.0 / 2,
                                    imageNamed: "icon-edit-blacklist-circle-red-default")
        
        let mainStackView = UIStackView(arrangedSubviews: [imageView, labelsStackView],
                                        axis: .horizontal,
                                        spacing: 10.0,
                                        alignment: .fill,
                                        distribution: .fillProportionally)
        
        addSubview(mainStackView)
        mainStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: 30.0, vertical: 34.0))
        addTapGesture()
    }
    
    private func addTapGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwiped))
        swipeDown.direction = .down
        addGestureRecognizer(swipeDown)
        isUserInteractionEnabled = true
    }

    func display(inPosition position: CGPoint, withType type: HintType = .enterText, andButtonHeight buttonHeight: CGFloat = 50.0, completion: (() -> Void)? = nil) {
        contentLabel.text = type.introduced()
        
        // Show
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1.0
            self.transform = CGAffineTransform(translationX: 0, y: -(100.0 + DeviceScreen.ScreenSize.height - position.y + (self.height - buttonHeight) / 2))
        }

        // Hide
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0.0
                self.transform = .identity
                completion?()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                    self.removeFromSuperview()
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc func didSwiped(_ sender: UISwipeGestureRecognizer) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0.0
                self.transform = .identity
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                    self.removeFromSuperview()
                }
            }
        }
    }
}
