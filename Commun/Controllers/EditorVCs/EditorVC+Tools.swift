//
//  EditorVC+Tools.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorVC {
    func insertTool(_ tool: EditorToolbarItem, at index: Int) {
        var tools = self.tools.value
        tools.insert(tool, at: index)
        self.tools.accept(tools)
    }
    
    func appendTool(_ tool: EditorToolbarItem) {
        var tools = self.tools.value
        tools.append(tool)
        self.tools.accept(tools)
    }
    
    func removeTool(_ tool: EditorToolbarItem) {
        let tools = self.tools.value.filter {$0 != tool}
        self.tools.accept(tools)
    }
}
