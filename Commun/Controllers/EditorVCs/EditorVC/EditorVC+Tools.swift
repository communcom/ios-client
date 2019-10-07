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
        tools.removeAll(tool)
        if index >= 0 && index < tools.count {
            tools.insert(tool, at: index)
            self.tools.accept(tools)
        }
    }
    
    func appendTool(_ tool: EditorToolbarItem) {
        var tools = self.tools.value
        tools.removeAll(tool)
        tools.append(tool)
        self.tools.accept(tools)
    }
    
    func removeTool(_ tool: EditorToolbarItem) {
        let tools = self.tools.value.filter {$0 != tool}
        self.tools.accept(tools)
    }
    
    func toggleIsHighlightedForTool(_ tool: EditorToolbarItem, isHighlighted: Bool? = nil)
    {
        guard var tool = tools.value.first(where: {$0 == tool}) else {return}
        tool.isHighlighted = isHighlighted ?? !tool.isHighlighted
        if let index = tools.value.firstIndex(of: tool) {
            var tools = self.tools.value
            tools[index] = tool
            self.tools.accept(tools)
        }
        else {
            appendTool(tool)
        }
    }
    
    func toggleIsEnabledForTool(_ tool: EditorToolbarItem, isEnabled: Bool? = nil)
    {
        guard var tool = tools.value.first(where: {$0 == tool}) else {return}
        tool.isEnabled = isEnabled ?? !tool.isEnabled
        if let index = tools.value.firstIndex(of: tool) {
            var tools = self.tools.value
            tools[index] = tool
            self.tools.accept(tools)
        }
        else {
            appendTool(tool)
        }
    }
    
    func setOtherOptionForTool(_ tool: EditorToolbarItem, value: Any?)
    {
        guard var tool = tools.value.first(where: {$0 == tool}) else {return}
        tool.other = value
        if tool == .setColor,
            let index = tools.value.firstIndex(of: tool)
        {
            var tools = self.tools.value
            tools[index] = tool
            self.tools.accept(tools)
        }
        else {
            appendTool(tool)
        }
    }
    
    // MARK: - immutable tools
    func hideKeyboard() {
        view.endEditing(true)
    }
}
