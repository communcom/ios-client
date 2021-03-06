//
//  CMToolbarView.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 23.12.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

class CMToolbarView: UIView {
    static let inset: CGFloat = 16
    static let titles: [CGFloat] = [1000, 10000, 100000, 1000000]
    
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
        let stackViewInstance = UIStackView(axis: .horizontal, spacing: .adaptive(width: 5.0))
        stackViewInstance.translatesAutoresizingMaskIntoConstraints = false
        stackViewInstance.distribution = .fillProportionally
        stackViewInstance.alignment = .center

        // Add buttons
        for (index, title) in titles.enumerated() {
            let actionButton = UIButton(
                width: .adaptive(width: 69.0 + CGFloat(7 * index)),
                height: 30,
                label: "+\(title.formattedWithSeparator)",
                labelFont: .systemFont(ofSize: .adaptive(width: 12.0), weight: .semibold),
                backgroundColor: UIColor.white.withAlphaComponent(0.1),
                textColor: .white,
                cornerRadius: .adaptive(width: 10.0)
            )
            
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
        let addLabel = UILabel.with(
            text: "add".localized().uppercaseFirst + ":",
            textSize: 12,
            weight: .bold,
            textColor: .white
        )

        addSubview(addLabel)
        addLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        addLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        scrollView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        stackView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.widthAnchor, constant: -CMToolbarView.inset * 2).isActive = true
        
        addSubview(scrollView)
        scrollView.autoPinEdge(.leading, to: .trailing, of: addLabel, withOffset: 10)
        scrollView.autoSetDimension(.height, toSize: 30)
        scrollView.autoAlignAxis(toSuperviewAxis: .horizontal)
        scrollView.autoPinEdge(toSuperviewEdge: .trailing)
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
        addCompletion!(CMToolbarView.titles[sender.tag])
    }
}
