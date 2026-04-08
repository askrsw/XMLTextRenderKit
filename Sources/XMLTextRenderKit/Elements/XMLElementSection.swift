//
//  XMLElementSection.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit
import SWXMLHash

final class XMLElementSection: XMLElementBase {
    let sectionTopPadding: CGFloat
    let sectionBottomPadding: CGFloat
    let structuredContents: [XMLElementBase]

    // MARK: - Interface

    required init(xml: XMLIndexer) {
        //
        sectionTopPadding = XMLElementBase.parseCGFloatValue(xml: xml, name: "section-toppadding") ?? 0
        sectionBottomPadding = XMLElementBase.parseCGFloatValue(xml: xml, name: "section-bottompadding") ?? 0
        structuredContents = XMLFileParser.parse(xml: xml)
        super.init(xml: xml)

        let fontsize = fontSize
        let alignment = textAlignment
        let toppadding = topPadding
        let bottompadding = bottomPadding
        let sectionLeading = leading
        let sectionTrailing = trailing
        for e in structuredContents {
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
            } else if let list = e as? XMLElementList {
                if list.hasFontSizeAttribute == false {
                    list.fontSize = fontsize
                }
                if list.hasAlignmentAttribute == false {
                    list.textAlignment = alignment
                }
                if list.hasTopPaddingAttribute == false {
                    list.topPadding = toppadding
                }
                if list.hasBottomPaddingAttribute == false {
                    list.bottomPadding = bottompadding
                }
                if list.hasLeadingAttribute == false {
                    list.leading = sectionLeading
                }
                if list.hasTrailingAttribute == false {
                    list.trailing = sectionTrailing
                }
            }
        }

        structuredContents.first?.topPadding += sectionTopPadding
        structuredContents.last?.bottomPadding += sectionBottomPadding
    }

    init(elements: [XMLElementBase], id: String?) {
        self.sectionTopPadding = 0
        self.sectionBottomPadding = 0
        self.structuredContents = elements
        super.init(id: id)

        structuredContents.first?.topPadding += sectionTopPadding
        structuredContents.last?.bottomPadding += sectionBottomPadding
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
