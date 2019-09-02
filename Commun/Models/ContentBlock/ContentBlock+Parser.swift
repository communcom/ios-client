//
//  ContentBlock+Parser.swift
//  CyberSwift
//
//  Created by Chung Tran on 8/29/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

class ContentBlockAttributedString: NSAttributedString {
    var block: ContentBlock?
}

extension NSAttributedString {
    static var separator: NSAttributedString {
        let separator = NSMutableAttributedString(string: "\n")
        separator.addAttribute(.paragraphStyle, value: NSParagraphStyle(), range: NSMakeRange(0, separator.length))
        return separator
    }
}

extension ContentBlock {
    func toHTML() -> String {
        
        var innerHTML = ""
        switch content {
        case .array(let array):
            for inner in array {
                innerHTML += inner.toHTML()
            }
        case .string(let string):
            innerHTML += string
        case .unsupported:
            break
        }
        
        // get styles
        var style = ""
        if let text_color = attributes?.text_color {
            style += "color: \(text_color);"
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
            return "<p>\(innerHTML)</p>"
        case "text":
            if style == "" {return innerHTML}
            return "<span style=\"\(style)\">\(innerHTML)</span>"
        case "tag":
            style = "color: blue;"
            return "<span style=\"\(style)\">#\(innerHTML)</span>"
        case "link":
            let url = attributes?.url ?? ""
            return "<a href=\"\(url)\">\(innerHTML)</a>"
        case "image":
            let description = attributes?.description ?? ""
            return "<div style=\"background-color: #F5F5F5;\"><img style=\"display: block; width: 100%; height: auto;\" src=\"\(innerHTML)\" /><p>\(description)</p></div>"
        case "video":
            return "<div style=\"position:relative;padding-top:56.25%;\"><iframe src=\"\(innerHTML)\" frameborder=\"0\" allowfullscreen style=\"position:absolute;top:0;left:0;width:100%;height:100%;\"></iframe></div>"
        case "website":
            // TODO: Preview
            return ""
        case "set":
            // TODO: Set grid style
            return "<div>\(innerHTML)</div>"
        default:
            return ""
        }
    }
    
    func toAttributedString(currentAttributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let child = NSMutableAttributedString()
        switch content {
        case .array(let array):
            for inner in array {
                child.append(inner.toAttributedString(currentAttributes: currentAttributes))
            }
            
        case .string(let string):
            child.append(NSAttributedString(string: string))
        case .unsupported:
            break
        }
        
        switch type {
        case "paragraph":
            child.addAttributes(currentAttributes, range: NSMakeRange(0, child.length))
            child.append(NSAttributedString.separator)
            return child
        case "text":
            var attr = currentAttributes
            if let text_color = attributes?.text_color {
                attr[.foregroundColor] = UIColor(hexString: text_color)
            }
    
            var symbolicTraits: UIFontDescriptor.SymbolicTraits = []
            if attributes?.style?.contains("bold") == true {
                symbolicTraits.insert(.traitBold)
            }
            
            if attributes?.style?.contains("italic") == true {
                symbolicTraits.insert(.traitItalic)
            }
    
            if !symbolicTraits.isEmpty {
                if let currentFont = attr[.font] as? UIFont {
                    attr[.font] = UIFont(descriptor: currentFont.fontDescriptor.withSymbolicTraits(symbolicTraits)!, size: currentFont.pointSize)
                }
            }
            child.addAttributes(attr, range: NSMakeRange(0, child.length))
            return child
        case "tag":
            child.insert(NSAttributedString(string: "#"), at: 0)
            var attr = currentAttributes
            attr[.foregroundColor] = UIColor.tag
            child.addAttributes(attr, range: NSMakeRange(0, child.length))
            return child
        case "link":
            let url = attributes?.url ?? ""
            var attr = currentAttributes
            attr[.link] = url
            child.addAttributes(attr, range: NSMakeRange(0, child.length))
            return child
        case "image":
            let description = attributes?.description ?? ""
            child.insert(NSAttributedString(string: "![\(description)]("), at: 0)
            child.append(NSAttributedString(string: ")"))
            child.addAttributes(currentAttributes, range: NSMakeRange(0, child.length))
            child.append(NSAttributedString.separator)
            return child
        case "video":
            // TODO: video
            child.insert(NSAttributedString(string: "!video[]("), at: 0)
            child.append(NSAttributedString(string: ")"))
            child.addAttributes(currentAttributes, range: NSMakeRange(0, child.length))
            child.append(NSAttributedString.separator)
            return child
        case "website":
            child.insert(NSAttributedString(string: "!website[]("), at: 0)
            child.append(NSAttributedString(string: ")"))
            child.addAttributes(currentAttributes, range: NSMakeRange(0, child.length))
            child.append(NSAttributedString.separator)
            return child
        case "set":
            // TODO: set
            child.append(NSAttributedString.separator)
            return child
        default:
            return child
        }
    }
}
