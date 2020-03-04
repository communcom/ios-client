//
//  CMAppLikeView.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 04.03.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMAppLikeView: MyCardView {
    // MARK: - Properties
    lazy var closeButton = UIButton.close(size: .adaptive(width: 24.0))

    lazy var actionButtonNo = UIButton.init(width: .adaptive(width: 100.0),
                                            height: .adaptive(height: 50.0),
                                            label: "no".localized().uppercaseFirst,
                                            labelFont: UIFont.systemFont(ofSize: .adaptive(width: 15.0), weight: .bold),
                                            backgroundColor: #colorLiteral(red: 0.647, green: 0.655, blue: 0.741, alpha: 1),
                                            textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
                                            cornerRadius: .adaptive(width: 50.0) / 2)
    
    lazy var actionButtonYes = UIButton.init(width: .adaptive(width: 210.0),
                                             height: .adaptive(height: 50.0),
                                             label: "yes".localized().uppercaseFirst,
                                             labelFont: UIFont.systemFont(ofSize: .adaptive(width: 15.0), weight: .bold),
                                             backgroundColor: #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1),
                                             textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
                                             cornerRadius: .adaptive(width: 50.0) / 2)

    
    // MARK: - Custom Functions
    override func commonInit() {
        super.commonInit()
        
        addSubview(closeButton)
        closeButton.autoPinTopAndTrailingToSuperView()
        
        let titleLabel = UILabel.with(text: viewParameters.title, textSize: .adaptive(width: 17.0), weight: .semibold)
        addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(width: 20.0))
        titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: closeButton)
        
        let noteLabel = UILabel.with(text: viewParameters.note, textSize: .adaptive(width: 15.0), weight: .medium, textColor: #colorLiteral(red: 0.647, green: 0.655, blue: 0.741, alpha: 1), numberOfLines: 0)
        addSubview(noteLabel)
        noteLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: .adaptive(width: 20.0))
        noteLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: .adaptive(width: 20.0))
        noteLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: .adaptive(height: 15.0))

        let buttonsStackView = UIStackView(axis: .horizontal, spacing: .adaptive(width: 10.0), alignment: .fill, distribution: .fillProportionally)
        buttonsStackView.addArrangedSubviews([ actionButtonNo, actionButtonYes])
        addSubview(buttonsStackView)
        buttonsStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 20), excludingEdge: .top)
        buttonsStackView.autoPinEdge(.top, to: .bottom, of: noteLabel, withOffset: .adaptive(height: 15.0))
        
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        actionButtonNo.addTarget(self, action: #selector(appLiked), for: .touchUpInside)
        actionButtonYes.addTarget(self, action: #selector(appLiked), for: .touchUpInside)
        actionButtonYes.tag = 1
    }
}
