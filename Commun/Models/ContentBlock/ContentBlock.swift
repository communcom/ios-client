//
//  ContentBlock.swift
//  CyberSwift
//
//  Created by Chung Tran on 8/29/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

struct ContentBlock: Codable {
    let id: UInt
    var type: String
    var attributes: ContentBlockAttributes?
    var content: ContentBlockContent
}

struct ContentBlockAttributes: Codable {
    // PostBlock
    var version: UInt?
    var title: String?
    
    // TextBlock
    var style: [String]?
    var text_color: String?
    
    // TagBlock
    var anchor: String?
    
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
