//
//  XMLTextContentQuery.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2026/4/7.
//

import Foundation

public enum XMLTextContentQuery {
    public static func listItems(xmlUrl: URL, listId: String) -> [String]? {
        guard
            let data = try? Data(contentsOf: xmlUrl),
            let content = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        let parser = XMLFileParser(content: content)
        return parser.listItems(forListId: listId)
    }

    public static func listAttributedString(xmlUrl: URL, listId: String) -> NSAttributedString? {
        guard
            let data = try? Data(contentsOf: xmlUrl),
            let content = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        let parser = XMLFileParser(content: content)
        return parser.attributedString(forListId: listId)
    }
}
