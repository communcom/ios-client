//
//  String.swift
//  Commun
//
//  Created by Chung Tran on 07/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension String {
    func getTags() -> [String] {
        var tags: [String] = []
        
        for word in components(separatedBy: " ") {
            if word.contains("#") {
                tags.append(word)
            }
        }
        return tags
    }
    
    func getJsonMetadata() -> [[String: String]] {
        var embeds = [[String: String]]()
        
        for word in components(separatedBy: " ") {
            if word.contains("http://") || word.contains("https://") {
                if embeds.first(where: {$0["url"] == word}) != nil {continue}
                #warning("Define type")
                embeds.append(["url": word])
            }
        }
        return embeds
    }
}
