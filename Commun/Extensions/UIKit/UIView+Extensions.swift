//
//  UIView+Loading.swift
//  Commun
//
//  Created by Chung Tran on 31/05/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import ASSpinnerView

extension UIView {
    // https://developer.apple.com/documentation/quartzcore/cashapelayer/1521921-linedashpattern#2825197
    public func draw(lineColor color: UIColor = .lightGray, lineWidth width: CGFloat = 1.0, startPoint start: CGPoint, endPoint end: CGPoint, withDashPattern lineDashPattern: [NSNumber]? = nil) {
        // Example of lineDashPattern: [nil, [2,3], [10, 5, 5, 5]]
        let shapeLayer = CAShapeLayer()

        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        shapeLayer.lineDashPattern = lineDashPattern

        let path = CGMutablePath()
        path.addLines(between: [start, end])
        shapeLayer.path = path

        layer.addSublayer(shapeLayer)
    }

    public func copyView() -> UIView? {
        NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as? UIView
    }
    
    func showErrorView(title: String? = nil, subtitle: String? = nil, retryButtonTitle: String? = nil, retryAction: (() -> Void)?) {
        // setup new errorView
        let errorView = ErrorView(title: title, subtitle: subtitle, retryButtonTitle: retryButtonTitle, retryAction: retryAction)
        
        // add subview
        addSubview(errorView)
        errorView.autoPinEdgesToSuperviewEdges()
        
    }
    
    func showForceUpdate() {
        // setup new errorView
        let errorView = ForceUpdateView()
        
        // add subview
        addSubview(errorView)
        errorView.autoPinEdgesToSuperviewEdges()
    }
    
    func hideErrorView() {
        subviews.forEach { (view) in
            if view is ErrorView {
                view.removeFromSuperview()
            }
        }
    }
    
    var isLoading: Bool {
        let loadingViewTag = ViewTag.loadingView.rawValue
        return subviews.count(where: {$0.tag == loadingViewTag}) > 0
    }
    
    func showLoading(
        cover: Bool = true,
        coverColor: UIColor = .appWhiteColor,
        spinnerColor: UIColor = #colorLiteral(red: 0.4784313725, green: 0.6470588235, blue: 0.8980392157, alpha: 1),
        size: CGFloat? = nil,
        spinerLineWidth: CGFloat? = nil,
        centerYOffset: CGFloat? = nil,
        offsetTop: CGFloat? = nil
    ) {
        // if loading view is existed
        let loadingViewTag = ViewTag.loadingView.rawValue
        if isLoading {return}
        
        // create cover view to cover all current view
        let coverView = UIView()
        coverView.backgroundColor = cover ? coverColor : .clear
        coverView.translatesAutoresizingMaskIntoConstraints = false
        coverView.tag = loadingViewTag
        self.addSubview(coverView)
        
        // add constraint for coverView
        coverView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        coverView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        coverView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 0).isActive = true
        coverView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 0).isActive = true
        self.bringSubviewToFront(coverView)
        
        // add spinnerView
        let size = size ?? (height > 76 ? 60: height-8)
        let spinnerView = ASSpinnerView()
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.spinnerLineWidth = spinerLineWidth ?? size/10
        spinnerView.spinnerDuration = 0.3
        spinnerView.spinnerStrokeColor = spinnerColor.cgColor
        coverView.addSubview(spinnerView)
        
        // add constraint for spinnerView
        spinnerView.centerXAnchor.constraint(equalTo: coverView.centerXAnchor, constant: 0).isActive = true
        if let offsetTop = offsetTop {
            spinnerView.autoPinEdge(toSuperviewEdge: .top, withInset: offsetTop)
        } else {
            spinnerView.centerYAnchor.constraint(equalTo: coverView.centerYAnchor, constant: centerYOffset ?? 0).isActive = true
        }
        
        spinnerView.widthAnchor.constraint(equalToConstant: size).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: size).isActive = true
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            let loadingViewTag = ViewTag.loadingView.rawValue
            for subview in self.subviews where subview.tag == loadingViewTag {
                subview.removeFromSuperview()
            }
        }
    }
    
    func shake() {
        let midX = center.x
        let midY = center.y
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 2
        animation.autoreverses = true
        
        animation.fromValue = CGPoint(x: midX-30, y: midY)
        animation.toValue = CGPoint(x: midX+30, y: midY)
        
        layer.add(animation, forKey: "position")
    }
    
    func removeConstraintToSuperView(withAttribute attribute: NSLayoutConstraint.Attribute) {
        guard let superview = superview else {return}
        if let constraint = superview.constraints.first(where: {(($0.firstItem as? UIView) == self || ($0.secondItem as? UIView) == self) && $0.firstAttribute == attribute}) {
            superview.removeConstraint(constraint)
        }
    }
    
    public func removeAllConstraints() {
        var _superview = self.superview

        while let superview = _superview {
            for constraint in superview.constraints {

                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }

                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }

            _superview = superview.superview
        }

        self.removeConstraints(self.constraints)
    }
    
    var topConstraint: NSLayoutConstraint? {
        return constraints.first(where: {$0.firstAttribute == .top})
    }
        
    var heightConstraint: NSLayoutConstraint? {
        return constraints.first(where: {$0.firstAttribute == .height && $0.secondItem == nil})
    }
    
    var leftConstraint: NSLayoutConstraint? {
        return superview?.constraints.first(where: {$0.firstAttribute == .leading && (($0.firstItem as? UIView) == self || ($0.secondItem as? UIView) == self)})
    }

    var widthConstraint: NSLayoutConstraint? {
        return constraints.first(where: {$0.firstAttribute == .width && $0.secondItem == nil})
    }
    
    func addBorder(width: CGFloat, radius: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.cornerRadius = radius
        self.layer.borderColor = color.cgColor
        self.clipsToBounds = true
    }
    
    func addExplanationView(id: String, title: String, description: String, imageName: String? = nil, from sender: UIView, showAbove: Bool = true, marginLeft: CGFloat = 0, marginRight: CGFloat = 0, learnMoreLink: String = "https://commun.com/faq") {
        if subviews.first(where: {($0 as? ExplanationView)?.id == id}) != nil {return}
        
        if !ExplanationView.shouldShowViewWithId(id) {
            return
        }
        
        let eView = ExplanationView(id: id, title: title, descriptionText: description, imageName: nil, senderView: sender, showAbove: showAbove, learnMoreLink: learnMoreLink)
        
        addSubview(eView)
        eView.fixArrowView()
        if showAbove {
            eView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: 10)
                .isActive = true
        } else {
            eView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
                .isActive = true
        }
        eView.autoPinEdge(toSuperviewEdge: .leading, withInset: marginLeft)
        eView.autoPinEdge(toSuperviewEdge: .trailing, withInset: marginRight)
        if showAbove {
            eView.autoPinEdge(.bottom, to: .top, of: sender)
        } else {
            eView.autoPinEdge(.top, to: .bottom, of: sender)
        }
    }
    
    func removeAllExplanationViews() {
        for subview in subviews where subview is ExplanationView {
            subview.removeFromSuperview()
        }
    }
    
    @discardableResult
    func onTap(_ target: Any?, action: Selector) -> Self {
        if self is UIButton {
            (self as? UIButton)?.addTarget(target, action: action, for: .touchUpInside)
            return self
        }
        let tap = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
        return self
    }
    
    @discardableResult
    func border(width: CGFloat, color: UIColor) -> Self {
        borderWidth = width
        borderColor = color
        return self
    }
    
    @discardableResult
    func whRatio(_ ratio: CGFloat) -> Self {
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: 335 / 150)
            .isActive = true
        return self
    }
    
    @discardableResult
    func huggingContent(axis: NSLayoutConstraint.Axis) -> Self {
        setContentHuggingPriority(.required, for: axis)
        return self
    }
    
    func fittingHeight(targetWidth: CGFloat) -> CGFloat {
        let fittingSize = CGSize(
            width: targetWidth,
            height: UIView.layoutFittingCompressedSize.height
        )
        return systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required,
                                verticalFittingPriority: .defaultLow)
            .height
    }
    
    static func withStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat? = nil, alignment: UIStackView.Alignment = .center, distribution: UIStackView.Distribution = .fillEqually, padding: UIEdgeInsets = .init(inset: 16)) -> UIView {
        let view = UIView(forAutoLayout: ())
        let stackView = UIStackView(axis: axis, spacing: spacing, alignment: alignment, distribution: distribution)
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        return view
    }
    
    var innerStackView: UIStackView? {subviews.first as? UIStackView}
}
