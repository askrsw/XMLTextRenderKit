//
//  XMLElementFooter.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit
import SWXMLHash

final class XMLElementFooter: XMLElementBase {
    private let content: String
    private let inlineNodes: [XMLInlineNode]
    private var _attributedString: NSAttributedString?
    private var _textFrame: CGRect = .zero

    // MARK: - Interface

    required init(xml: XMLIndexer) {
        content = xml.element!.text
        inlineNodes = XMLInlineNodeParser.parseNodes(from: xml)
        super.init(xml: xml)

        topPadding = Self.parseCGFloatValue(xml: xml, name: "toppadding") ?? 15
        bottomPadding = Self.parseCGFloatValue(xml: xml, name: "bottompadding") ?? 6
    }

    override var attributedString: NSAttributedString? {
        if _attributedString == nil {
            buildAttributedString()
        }

        return _attributedString
    }

    override var cellHeight: CGFloat {
        if _attributedString == nil {
            buildAttributedString()
        }

        return topPadding + bottomPadding + _textFrame.maxY
    }

    var textFrame: CGRect {
        _textFrame
    }

    override func clearAttributedString() {
        _attributedString = nil
    }

    // MARK: - Utils

    private lazy var textAttributes = { (
        color: UIColor,
        underline: Bool,
        isBold: Bool,
        isItalic: Bool
    ) -> [NSAttributedString.Key: Any] in
        let fontSize: CGFloat = 14.0
        let font: UIFont = {
            if isBold && isItalic {
                let descriptor = UIFontDescriptor(name: "TimesNewRomanPSMT", size: fontSize)
                    .withSymbolicTraits([.traitBold, .traitItalic])
                if let descriptor {
                    return UIFont(descriptor: descriptor, size: fontSize)
                }
                return UIFont.systemFont(ofSize: fontSize, weight: .semibold)
            }
            if isBold {
                return UIFont(name: "TimesNewRomanPS-BoldMT", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
            }
            if isItalic {
                return UIFont(name: "TimesNewRomanPS-ItalicMT", size: fontSize) ?? UIFont.italicSystemFont(ofSize: fontSize)
            }
            return UIFont(name: "TimesNewRomanPSMT", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        }()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0.0
        paragraphStyle.headIndent = 0.0
        paragraphStyle.tailIndent = 0.0
        paragraphStyle.lineSpacing = 4.0

        let underlineStyle: NSUnderlineStyle = underline ? .single : []
        return [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
            .underlineStyle: underlineStyle.rawValue
        ]
    }

    private func buildAttributedString() {
        let nodes = inlineNodes.isEmpty ? [.text(content)] : inlineNodes
        let renderer = XMLInlineRenderer { [weak self] style in
            let color = style.isLink ? UIColor.link : UIColor.label
            var attributes = self?.textAttributes(color, style.isLink, style.isBold, style.isItalic) ?? [:]
            if let url = style.url {
                attributes[.link] = url
            }
            return attributes
        }
        let attributedString = renderer.render(nodes: nodes)

        if attributedString.length == 0 {
            attributedString.append(NSAttributedString(
                string: content,
                attributes: textAttributes(.label, false, false, false)
            ))
        }

        let boldAttributes = textAttributes(.label, false, true, false)
        XMLRegexPatterns.parseSpecialFont(attributedString: attributedString, pattern: XMLRegexPatterns.boldText, attributes: boldAttributes)

        let italicAttributes = textAttributes(.label, false, false, true)
        XMLRegexPatterns.parseSpecialFont(attributedString: attributedString, pattern: XMLRegexPatterns.italicText, attributes: italicAttributes)

        let linkAttributes = textAttributes(.link, true, false, false)
        XMLRegexPatterns.parsePasteActionText(attributedString: attributedString, attributes: linkAttributes)
        XMLRegexPatterns.parseLinkText(attributedString: attributedString, attributes: linkAttributes)
        XMLRegexPatterns.parseNewParagraphMark(attributedString: attributedString)

        _attributedString = attributedString

        let width = viewWidth - leading - trailing
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        _textFrame = attributedString.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        _textFrame.size.height += 5
        _textFrame.origin.x = leading
        _textFrame.origin.y = 5
    }
}
