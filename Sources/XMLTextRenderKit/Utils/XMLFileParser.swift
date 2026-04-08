//
//  XMLFileParser.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import Foundation
import SWXMLHash

final class XMLFileParser {
    let xml: XMLIndexer
    let structuredContents: [XMLElementBase]

    var flattenContents: [XMLElementBase] {
        var results = [XMLElementBase]()
        for item in structuredContents {
            results.append(contentsOf: item.flattenContents)
        }
        return results
    }

    var contentSections: [XMLElementSection] {
        structuredContents.compactMap({ $0 as? XMLElementSection })
    }

    init(content: String) {
        xml = XMLHash.parse(content)["p-contents"]
        structuredContents = XMLFileParser.parse(xml: xml)
    }

    static var mappedClass: [String: XMLElementBase.Type] {
        [
            "main-title": XMLElementTitle.self,
            "p-title": XMLElementTitle.self,
            "p-section":  XMLElementSection.self,
            "p-paragraph": XMLElementParagraph.self,
            "p-list": XMLElementList.self,
            "p-footer": XMLElementFooter.self,
            "p-images": XMLElementImages.self
        ]
    }

    static func parse(xml: XMLIndexer) -> [XMLElementBase] {
        var briefTextUnits: [XMLElementBase] = []
        for child in xml.children {
            let nodeName = child.element!.name
            guard let childClass = mappedClass[nodeName] else {
                let errMsg = "Cannot map xml node name: \(nodeName) to an instance of BriefTextTypeBase."
                print(errMsg)
                fatalError(errMsg)
            }

            briefTextUnits.append(childClass.init(xml: child))
        }

        return briefTextUnits
    }

    func listItems(forListId targetId: String) -> [String]? {
        guard let list = flattenContents.first(where: { $0.id == targetId }) as? XMLElementList else {
            return nil
        }
        return list.itemTexts
    }

    func attributedString(forListId targetId: String) -> NSAttributedString? {
        guard let list = flattenContents.first(where: { $0.id == targetId }) as? XMLElementList else {
            return nil
        }
        return list.attributedString
    }
}
