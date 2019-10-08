//
//  ContentBlock.swift
//  CyberSwift
//
//  Created by Chung Tran on 8/29/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import CyberSwift

struct ContentBlock: Codable {
    let id: UInt
    var type: String
    var attributes: ContentBlockAttributes?
    var content: ContentBlockContent
}

extension ResponseAPIFrameGetEmbed {
    init(blockAttributes: ContentBlockAttributes) throws {
        let data = try JSONEncoder().encode(blockAttributes)
        self = try JSONDecoder().decode(ResponseAPIFrameGetEmbed.self, from: data)
    }
}

struct ContentBlockAttributes: Codable {
    init(embed: ResponseAPIFrameGetEmbed) {
        self.title          =   embed.title
        self.url            =   embed.url
        self.description    =   embed.description
        self.provider_name  =   embed.provider_name
        self.author         =   embed.author
        self.author_url     =   embed.author_url
        self.thumbnail_url  =   embed.thumbnail_url
        self.html           =   embed.html
    }
    
    init(
        title: String? = nil,
        type: String? = nil,
        version: String? = nil,
        style: [String]? = nil,
        text_color: String? = nil,
        url: String? = nil,
        description: String? = nil,
        provider_name: String? = nil,
        author: String? = nil,
        author_url: String? = nil,
        thumbnail_url: String? = nil,
        thumbnail_size: [UInt]? = nil,
        html: String? = nil
    ){
        self.title = title
        self.type = type
        self.version = version
        self.style = style
        self.text_color = text_color
        self.url = url
        self.description = description
        self.provider_name = provider_name
        self.author = author
        self.author_url = author_url
        self.thumbnail_url = thumbnail_url
        self.thumbnail_size = thumbnail_size
        self.html = html
    }
    
    // PostBlock
    var title: String?
    var type: String?
    var version: String?
    
    // TextBlock
    var style: [String]?
    var text_color: String?
    
    // LinkBlock
    var url: String?
    
    // ImageBlock
    var description: String?
    
    // VideoBlock
    var provider_name: String?
    var author: String?
    var author_url: String?
    var thumbnail_url: String?
    var thumbnail_size: [UInt]?
    var html: String?
}

enum ContentBlockContent {
    case array([ContentBlock])
    case string(String)
    case unsupported
    
    var stringValue: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    
    var arrayValue: [ContentBlock]? {
        switch self {
        case .array(let array):
            return array
        default:
            return nil
        }
    }
}
extension ContentBlockContent: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .array(let array):
            try container.encode(array)
        case .string(let string):
            try container.encode(string)
        case .unsupported:
            let context = EncodingError.Context(codingPath: [], debugDescription: "Invalid content")
            throw EncodingError.invalidValue(self, context)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let array = try? container.decode([ContentBlock].self) {
            self = .array(array)
            return
        }
        
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }
        
        self = .unsupported
    }
}
