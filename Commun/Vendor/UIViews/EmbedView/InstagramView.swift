//
//  InstagramView.swift
//  Commun
//
//  Created by Artem Shilin on 25.11.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import SafariServices

class InstagramView: UIView {
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var autorView: UIView!
    @IBOutlet weak private var backgroundView: UIView!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textView: UILabel!
    @IBOutlet weak private var autorLabel: UILabel!
    @IBOutlet weak private var providerLabel: UILabel!
    @IBOutlet weak private var providerImageView: UIImageView!

    private var isPostDetail = false

    private var content: ResponseAPIContentBlock!

    private func configureXib() {
        Bundle.main.loadNibNamed("InstagramView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = frame
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    init(content: ResponseAPIContentBlock, isPostDetail: Bool = false) {
        super.init(frame: .zero)
        self.isPostDetail = isPostDetail
        self.content = content
        self.configureXib()
        self.backgroundColor = .appWhiteColor
        self.configure(content: content)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(content: ResponseAPIContentBlock) {
        imageView.backgroundColor = .appLightGrayColor
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = UIColor.colorSupportDarkMode(defaultColor: UIColor(hexString: "#E9ECF1")!, darkColor: .appLightGrayColor).cgColor
        let providerName = content.attributes?.providerName

        let multiplier = (CGFloat(content.attributes?.thumbnailWidth ?? 640) / CGFloat(content.attributes?.thumbnailHeight ?? 640))

        if let urlString = content.attributes?.thumbnailUrl {
            imageView.setImageDetectGif(with: urlString)
            NSLayoutConstraint(item: imageView!, attribute: .width, relatedBy: .equal, toItem: imageView!, attribute: .height, multiplier: multiplier, constant: 0).isActive = true
            imageView.autoPinEdge(.bottom, to: .top, of: autorView, withOffset: -15)
            imageView.isHidden = false
            textView.isHidden = true
        } else {
            textView.autoPinEdge(.bottom, to: .top, of: autorView, withOffset: -15)
            imageView.isHidden = true
            textView.isHidden = false

            var text = content.attributes?.description
            if providerName == "twitter" {
                text = text?.replacingOccurrences(of: "\n\n", with: "")
                var texts = text?.components(separatedBy: "—")
                if (texts?.count ?? 0) > 1 {
                    texts?.removeLast()
                }
                text = texts.map({$0.joined(separator: "-")})
            }
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 2.2

            let defaultAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 15),
                .paragraphStyle: paragraph
            ]
            textView.attributedText = NSAttributedString(string: text ?? "", attributes: defaultAttributes)
        }

        if let providerUrlString = content.attributes?.url, let url = URL(string: providerUrlString) {
            providerLabel.text = InstagramView.getRightHostName(url: url)
        }

        autorLabel.text = content.attributes?.author

        if providerName == "twitter" {
            providerImageView.image = UIImage(named: "provider-twitter")
        } else if providerName == "instagram" {
            providerImageView.image = UIImage(named: "provider-instagram")
        } else {
            providerImageView.image = UIImage(named: "provider-other")
        }

        if isPostDetail {
            autorView.isUserInteractionEnabled = true
            autorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openUrlAction)))

            imageView.isUserInteractionEnabled = true
            imageView.addTapToViewer()
        }

    }

    @objc private func openUrlAction() {
        if let url = URL(string: content.attributes?.url ?? "") {
            let safariVC = SFSafariViewController(url: url)
            parentViewController?.present(safariVC, animated: true, completion: nil)
        }
    }

    static func getRightHostName(url: URL) -> String {
        return url.host?.replacingOccurrences(of: "www.", with: "").uppercaseFirst ?? ""
    }

}
