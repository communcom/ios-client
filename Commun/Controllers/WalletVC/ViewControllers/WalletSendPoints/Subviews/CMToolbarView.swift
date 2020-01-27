//
//  CMToolbarView.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 23.12.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

let inset: CGFloat = CGFloat.adaptive(width: 20.0)
let titles: [CGFloat] = [1000, 10000, 100000, 1000000]

class CMToolbarView: UIView {
    // MARK: - Properties
    var addCompletion: ((CGFloat) -> Void)?
    
    var scrollView: UIScrollView = {
        let scrollViewInstance = UIScrollView()
        scrollViewInstance.translatesAutoresizingMaskIntoConstraints = false
        scrollViewInstance.contentInset.left = 0.0
        scrollViewInstance.contentInset.right = inset
        scrollViewInstance.showsHorizontalScrollIndicator = false
        
        return scrollViewInstance
    }()
    
    var stackView: UIStackView = {
        let stackViewInstance = UIStackView(axis: .horizontal, spacing: CGFloat.adaptive(width: 5.0))
        stackViewInstance.translatesAutoresizingMaskIntoConstraints = false
        stackViewInstance.distribution = .fillProportionally
        stackViewInstance.alignment = .center

        // Add buttons
        for (index, title) in titles.enumerated() {
            let actionButton = UIButton.init(width: CGFloat.adaptive(width: 69.0 + CGFloat(7 * index)),
                                             height: CGFloat.adaptive(height: 30.0),
                                             backgroundColor: UIColor(hexString: "#ffffff", transparency: 0.1),
                                             cornerRadius: CGFloat.adaptive(width: 10.0))
            
            actionButton.translatesAutoresizingMaskIntoConstraints = false

            actionButton.tune(withTitle: "+\(title.formattedWithSeparator)", hexColors: [whiteColorPickers, lightGrayishBlueBlackColorPickers, lightGrayishBlueBlackColorPickers, lightGrayishBlueBlackColorPickers], font: UIFont.systemFont(ofSize: CGFloat.adaptive(width: 12.0), weight: .semibold), alignment: .center)
            
            actionButton.addTarget(self, action: #selector(selectPointTapped), for: .touchUpInside)
            actionButton.tag = index
            
            stackViewInstance.addArrangedSubview(actionButton)
        }
        
        return stackViewInstance
    }()

    
    // MARK: - Class Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Custom Functions
    func setupView() {
        setGradientBackground()
        
        // Add label
        let addLabel = UILabel()
        addLabel.tune(withText: "add".localized().uppercaseFirst + ":",
                      hexColors: whiteColorPickers,
                      font: UIFont.systemFont(ofSize: CGFloat.adaptive(width: 12.0), weight: .bold),
                      alignment: .left,
                      isMultiLines: false)

        addSubview(addLabel)
        addLabel.autoPinTopAndLeadingToSuperView(inset: CGFloat.adaptive(height: 19.0), xInset: CGFloat.adaptive(width: 15.0))
        
        scrollView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        stackView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.widthAnchor, constant: -inset * 2).isActive = true

        addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: CGFloat.adaptive(height: 10.0),
                                                                   left: CGFloat.adaptive(width: 59.0),
                                                                   bottom: CGFloat.adaptive(height: 10.0),
                                                                   right: 0.0))
    }
    
    private func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [
            UIColor(red: 0.159, green: 0.132, blue: 0.237, alpha: 1).cgColor,
            UIColor(red: 0.099, green: 0.067, blue: 0.229, alpha: 1).cgColor
        ]

        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds

        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    // MARK: - Actions
    @objc func selectPointTapped(_ sender: UIButton) {
        addCompletion!(titles[sender.tag])
    }
}
