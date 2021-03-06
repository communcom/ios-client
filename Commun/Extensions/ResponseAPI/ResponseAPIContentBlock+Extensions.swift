//
//  ResponseAPIContentBlock.swift
//  Commun
//
//  Created by Chung Tran on 10/9/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import SubviewAttachingTextView

extension ResponseAPIContentBlock {
    func toHTML() -> String {
        
        var innerHTML = ""
        switch content {
        case .array(let array):
            for inner in array {
                innerHTML += inner.toHTML()
            }
        case .string(let string):
            innerHTML += string.replacingOccurrences(of: "\n", with: "<br/>")
        case .unsupported:
            break
        }
        
        // get styles
        var style = ""
        if let textColor = attributes?.textColor {
            style += "color: \(textColor);"
        }
        
        if attributes?.style?.contains("bold") == true {
            style += "font-weight: bold;"
        }
        
        if attributes?.style?.contains("italic") == true {
            style += "font-style: italic;"
        }
        
        switch type {
        case "post":
            return innerHTML
        case "paragraph":
            return "<p class=\"paragraph\">\(innerHTML)</p>"
        case "text":
            if style == "" {return innerHTML}
            return "<span style=\"\(style)\">\(innerHTML)</span>"
        case "tag":
            return "<a href=\"\(URL.appURL)/#\(innerHTML)\">#\(innerHTML)</a>"
        case "mention":
            return "<a href=\"\(URL.appURL)/@\(innerHTML)\">@\(innerHTML)</a>"
        case "link":
            let url = attributes?.url ?? ""
            return "<a href=\"\(url)\">\(innerHTML)</a>"
        case "image":
            let description = attributes?.description
            return "<div class=\"embeded\"><img style=\"display: block; width: 100%; height: auto;\" src=\"\(innerHTML)\" onerror=\"this.src='\(Bundle.main.url(forResource: "image-not-available", withExtension: "jpg")?.absoluteString ?? "")';\"/>\(description != nil ? "<p class=\"description\">\(description!)</p>": "") </div>"
        case "video":
            
            let component: String
            if let html = attributes?.html {
                component = html
            } else {
                component = "<a href=\"\(attributes?.url ?? "")\"><img style=\"display: block; width: 100%; height: auto;\" src=\"\(attributes?.thumbnailUrl ?? "")\" /></a>"
            }
            
            let description = attributes?.title ?? attributes?.description
            return "<div class=\"embeded\">\(component)\(attributes?.url != nil ? "<p class=\"url\">\(attributes?.url ?? "")</p>": "")\(description != nil ? "<p class=\"description\">\(description!)</p>": "")</div>"
        case "website":
            
            let description = attributes?.description ?? attributes?.title
            return "<div class=\"embeded\"><a href=\"\(attributes?.url ?? "")\"><img style=\"display: block; width: 100%; height: auto;\" src=\"\(attributes?.thumbnailUrl ?? "")\" onerror=\"this.src='\(Bundle.main.url(forResource: "image-not-available", withExtension: "jpg")?.absoluteString ?? "")';\" /></a>\(attributes?.url != nil ? "<p class=\"url\">\(attributes?.url ?? "")</p>": "")\(description != nil ? "<p class=\"description\">\(description!)</p>": "")</div>"
        default:
            return innerHTML
        }
    }
    
    func toAttributedString<Attachment: SubviewTextAttachment & TextAttachmentType>(currentAttributes: [NSAttributedString.Key: Any], attachmentSize: CGSize = .zero, attachmentType: Attachment.Type, shouldAddParagraphSeparator: Bool = true) -> NSAttributedString {
        let child = NSMutableAttributedString()
        switch content {
        case .array(let array):
            for inner in array {
                child.append(inner.toAttributedString(currentAttributes: currentAttributes, attachmentSize: attachmentSize, attachmentType: attachmentType))
            }
            
        case .string(let string):
            if type != "website" && type != "image" && type != "video" && type != "embed" {
                child.append(NSAttributedString(string: string))
            }
        case .unsupported:
            break
        }
        
        switch type {
        case "paragraph":
            if shouldAddParagraphSeparator {
                child.append(NSAttributedString(string: "\r", attributes: currentAttributes))
            }
        case "text":
            var attr = currentAttributes
            // TODO: - Enable textColor later in Article Post
//            if let hexString = attributes?.textColor,
//                let textColor = UIColor(hexString: hexString),
//                textColor != .appWhiteColor
//            {
//                attr[.foregroundColor] = textColor
//            }
    
            var symbolicTraits: UIFontDescriptor.SymbolicTraits = []
            if attributes?.style?.contains("bold") == true {
                symbolicTraits.insert(.traitBold)
            }
            
            if attributes?.style?.contains("italic") == true {
                symbolicTraits.insert(.traitItalic)
            }
    
            if !symbolicTraits.isEmpty {
                if let currentFont = attr[.font] as? UIFont {
                    attr[.font] = UIFont(descriptor: currentFont.fontDescriptor.withFamily(currentFont.familyName).withSymbolicTraits(symbolicTraits)!, size: currentFont.pointSize)
                }
            }
            child.addAttributes(attr, range: NSRange(location: 0, length: child.length))
        case "tag":
            let link = child.string
            child.insert(NSAttributedString(string: "#"), at: 0)
            var attr = currentAttributes
            attr[.link] = "\(URL.appURL)/#\(link.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? link)"
            child.addAttributes(attr, range: NSRange(location: 0, length: child.length))
        case "mention":
            let link = child.string
            child.insert(NSAttributedString(string: "@"), at: 0)
            var attr = currentAttributes
            attr[.link] = "\(URL.appURL)/@\(link)"
            child.addAttributes(attr, range: NSRange(location: 0, length: child.length))
        case "link":
            let url = attributes?.url ?? ""
            var attr = currentAttributes
            attr[.link] = url
            child.addAttributes(attr, range: NSRange(location: 0, length: child.length))
        case "image", "video", "website", "embed":
            if attachmentSize == .zero { break }
            // get url
            var url: String?
            if type == "image" {
                url = content.stringValue ?? attributes?.url
            } else {
                url = content.stringValue ?? attributes?.thumbnailUrl
            }
            
            guard url != nil else {
                return NSAttributedString()
            }
            
            // set up attributes
            var attrs = attributes ?? ResponseAPIContentBlockAttributes(
                type: type,
                url: url)
            
            attrs.type = type
            attrs.url = url
            
            // attachment
            let attachment = Attachment(block: self, size: attachmentSize)
            let attachmentAS = NSAttributedString(attachment: attachment)
            child.append(attachmentAS)
            
            if shouldAddParagraphSeparator {
                child.append(NSAttributedString(string: "\r", attributes: currentAttributes))
            }
        case "attachments":
            break
        default:
            child.addAttributes(currentAttributes, range: NSRange(location: 0, length: child.length))
        }
        
        return child
    }
}
