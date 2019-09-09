//
//  ContentBlock+Parser.swift
//  CyberSwift
//
//  Created by Chung Tran on 8/29/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import CyberSwift

class ContentBlockAttributedString: NSAttributedString {
    var block: ContentBlock?
}

extension NSAttributedString {
    static var separator: NSAttributedString {
        // \u2063 means Invisible Separator
        let separator = NSMutableAttributedString(string: "\n")
        return separator
    }
}

extension ContentBlock {
    func jsonString() throws -> String {
        let data = try JSONEncoder().encode(self)
        guard let string = String(data: data, encoding: .utf8) else {
            throw ErrorAPI.invalidData(message: "Could not parse string from block")
        }
        return string
    }
    
    func getTags() -> [String] {
        var tags = [String]()
        switch content {
        case .array(let childBlocks):
            for block in childBlocks {
                tags += block.getTags()
            }
        case .string(let string):
            if type == "tag" {
                return [string]
            }
        case .unsupported:
            break
        }
        return tags
    }
    
    func toHTML(embeds: [ResponseAPIContentEmbedResult]) -> String {
        
        var innerHTML = ""
        switch content {
        case .array(let array):
            for inner in array {
                innerHTML += inner.toHTML(embeds: embeds)
            }
        case .string(let string):
            innerHTML += string.replacingOccurrences(of: "\n", with: "<br/>")
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
            let description = attributes?.description
            return "<div class=\"embeded\"><img style=\"display: block; width: 100%; height: auto;\" src=\"\(innerHTML)\" />\(description != nil ? "<p>\(description!)</p>": "") </div>"
        case "video":
            let embed = embeds.first(where: {embed in
                embed.url == innerHTML
            })
            
            let component: String
            if let html = embed?.html {
                component = html
            } else {
                component = "<a href=\"\(attributes?.url ?? "")\"><img style=\"display: block; width: 100%; height: auto;\" src=\"\(attributes?.thumbnail_url ?? "")\" /></a>"
            }
            
            let description = attributes?.title
            return "<div class=\"embeded\">\(component)\(description != nil ? "<p>\(description!)</p>": "")</div>"
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
            if type != "website" && type != "image" && type != "video" {
                child.append(NSAttributedString(string: string))
            }
        case .unsupported:
            break
        }
        
        switch type {
        case "paragraph":
            child.append(NSAttributedString.separator)
            child.addAttributes(currentAttributes, range: NSMakeRange(child.length - 1, 1))
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
            let link = child.string
            child.insert(NSAttributedString(string: "#"), at: 0)
            var attr = currentAttributes
            attr[.link] = "hash:\(link)"
            child.addAttributes(attr, range: NSMakeRange(0, child.length))
            return child
        case "link":
            let url = attributes?.url ?? ""
            var attr = currentAttributes
            attr[.link] = url
            child.addAttributes(attr, range: NSMakeRange(0, child.length))
            return child
        case "image", "video", "website":
            // Atachment
            guard let attributes = attributes,
                let embed = try? ResponseAPIFrameGetEmbed(blockAttributes: attributes)
            else {return NSAttributedString()}
            
            let attachment = TextAttachment()
            attachment.embed = embed
            attachment.embed?.type = type
            
            switch content {
            case .string(let url):
                attachment.embed!.url = url
            default:
                break
            }
            
            let attachmentAS = NSAttributedString(attachment: attachment)
            child.append(attachmentAS)
            child.append(NSAttributedString.separator)
            child.addAttributes(currentAttributes, range: NSMakeRange(child.length - 1, 1))
            return child
        default:
            return child
        }
    }
}
