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
    enum HintType: String {
        case enterText = "hint type enter text"
        case enterAmount = "hint type enter amount"
        case enterTextPhoto = "hint type enter text or photo"
        case enterDifferentText = "hint type enter different text"
        
        case chooseFriend = "hint type choose friend"
        case chooseProblem = "hint type choose problem"
        case chooseCommunity = "hint type choose community"
    }
    
    var type: HintType
    private var tabbarHeight: CGFloat = 0.0
    
    var topicLabel = UILabel(text: "warning".localized().uppercaseFirst,
                             font: .systemFont(ofSize: .adaptive(width: 15.0), weight: .bold),
                             numberOfLines: 0,
                             color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))

    lazy var contentLabel: UILabel = {
        let contentLabelInstance = UILabel(text: "",
                                           font: .systemFont(ofSize: .adaptive(width: 12.0), weight: .medium),
                                           numberOfLines: 0,
                                           color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        
        contentLabelInstance.translatesAutoresizingMaskIntoConstraints = false
        contentLabelInstance.alpha = 0.6
        
        return contentLabelInstance
    }()
    
    
    // MARK: - Class Initialization
    init(type: HintType, isTabbarHidden: Bool) {
        self.type = type
        self.tabbarHeight = CGFloat((!isTabbarHidden).int) * tabBarHeight
        
        super.init(frame: CGRect(origin: CGPoint(x: .adaptive(width: 15.0), y: DeviceScreen.ScreenSize.height + 100.0),
                                 size: CGSize(width: .adaptive(width: 345.0), height: .adaptive(height: 64.0))))

        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("XXX")
    }
    
    
    // MARK: - Custom Functions
    func commonInit() {
        alpha = 0.0
        backgroundColor = #colorLiteral(red: 0.141, green: 0.141, blue: 0.173, alpha: 1)
        layer.cornerRadius = .adaptive(width: 10.0)
        
        let labelsStackView = UIStackView(arrangedSubviews: [topicLabel, contentLabel],
                                          axis: .vertical,
                                          spacing: .adaptive(height: 2.0),
                                          alignment: .fill,
                                          distribution: .fillProportionally)
        
        let imageView = UIImageView(width: .adaptive(width: 30.0),
                                    height: .adaptive(width: 30.0),
                                    cornerRadius: .adaptive(width: 30.0) / 2,
                                    imageNamed: "icon-edit-blacklist-circle-red-default")
        
        let mainStackView = UIStackView(arrangedSubviews: [imageView, labelsStackView],
                                        axis: .horizontal,
                                        spacing: .adaptive(width: 10.0),
                                        alignment: .fill,
                                        distribution: .fillProportionally)
        
        addSubview(mainStackView)
        mainStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: .adaptive(width: 30.0), vertical: .adaptive(height: 34.0)))
    }
    
    func display(withType type: HintType = .enterText, completion: (() -> Void)?) {
        contentLabel.text = type.rawValue.localized().uppercaseFirst

        // Show
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1.0
            self.transform = CGAffineTransform(translationX: 0, y: -(100.0 + self.safeAreaInsets.bottom + self.bounds.height + .adaptive(height: self.tabbarHeight + (self.tabbarHeight == 0.0 ? 10.0 : 15.0))))
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
}
