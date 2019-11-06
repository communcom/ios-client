//
//  GridView.swift
//  Commun
//
//  Created by Chung Tran on 9/10/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

class GridView: UIView {
    // MARK: - Properties
    var padding: CGFloat = 0.5
    var views = [UIView]()
    var embedView: UIView?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .white
    }
    
    func setUp(embeds: [ResponseAPIContentBlock]) {
        embedView?.removeFromSuperview()
        embedView = nil

        if let embed = embeds.first {
            let view = EmbedView(content: embed)
            embedView = view
            addSubview(view)

            view.autoPinEdge(toSuperviewEdge: .top)
            view.autoPinEdge(toSuperviewEdge: .left)
            view.autoPinEdge(toSuperviewEdge: .right)
            view.autoPinEdge(toSuperviewEdge: .bottom)
        }
    }

    private func createVideoEmbed(_ embed: ResponseAPIContentBlock) {

    }

    private func createLinkEmbed(_ embed: ResponseAPIContentBlock) {

    }

    private func createGifEmbed(_ embed: ResponseAPIContentBlock) {

    }
}
