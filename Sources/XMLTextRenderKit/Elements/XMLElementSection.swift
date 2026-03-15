//
//  XMLElementSection.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit
import SWXMLHash

final class XMLElementSection: XMLElementBase {
    let id: String
    let block: Bool
    let structuredContents: [XMLElementBase]

    // MARK: - Interface

    required init(xml: XMLIndexer) {
        id = XMLElementBase.parseStringValue(xml: xml, name: "id")!
        block = XMLElementBase.parseBoolValue(xml: xml, name: "block") ?? false
        structuredContents = XMLFileParser.parse(xml: xml)
        super.init(xml: xml)

        let fontsize = fontSize
        let alignment = textAlignment
        let toppadding = topPadding
        let bottompadding = bottomPadding
        let sectionLeading = leading
        let sectionTrailing = trailing
        for e in structuredContents {
            e.updateBlockSection(block)
            if let paragraph = e as? XMLElementParagraph {
                if paragraph.hasFontSizeAttribute == false {
                    paragraph.fontSize = fontsize
                }
                if paragraph.hasAlignmentAttribute == false {
                    paragraph.textAlignment = alignment
                }
                if paragraph.hasTopPaddingAttribute == false {
                    paragraph.topPadding = toppadding
                }
                if paragraph.hasBottomPaddingAttribute == false {
                    paragraph.bottomPadding = bottompadding
                }
                if paragraph.hasLeadingAttribute == false {
                    paragraph.leading = sectionLeading
                }
                if paragraph.hasTrailingAttribute == false {
                    paragraph.trailing = sectionTrailing
                }
            } else if let title = e as? XMLElementTitle {
                if title.hasFontSizeAttribute == false {
                    title.fontSize = fontsize
                }
                if title.hasAlignmentAttribute == false {
                    title.textAlignment = alignment
                }
                if title.hasTopPaddingAttribute == false {
                    title.topPadding = toppadding
                }
                if title.hasBottomPaddingAttribute == false {
                    title.bottomPadding = bottompadding
                }
                if title.hasLeadingAttribute == false {
                    title.leading = sectionLeading
                }
                if title.hasTrailingAttribute == false {
                    title.trailing = sectionTrailing
                }
            }
        }

        if block {
            structuredContents.first?.topPadding = 15
            structuredContents.last?.bottomPadding = 15
        }
    }

    init(elements: [XMLElementBase], id: String, block: Bool = true) {
        self.id = id
        self.block = block
        self.structuredContents = elements
        super.init()

        for e in structuredContents {
            e.updateBlockSection(block)
        }

        if block {
            structuredContents.first?.topPadding = 15
            structuredContents.last?.bottomPadding = 15
        }
    }

    override var viewWidth: CGFloat {
        didSet {
            for e in structuredContents {
                e.viewWidth = viewWidth
            }
        }
    }

    override var flattenContents: [XMLElementBase] {
        var results = [XMLElementBase]()
        for item in structuredContents {
            results.append(contentsOf: item.flattenContents)
        }
        return results
    }

    override func clearAttributedString() {
        structuredContents.forEach({ $0.clearAttributedString() })
    }
}
