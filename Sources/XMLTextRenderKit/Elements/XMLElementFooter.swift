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
    private var _attributedString: NSAttributedString?
    private var _textFrame: CGRect = .zero

    // MARK: - Interface

    required init(xml: XMLIndexer) {
        content = xml.element!.text
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

    private func buildAttributedString() {
        let linkAttributes: [NSAttributedString.Key: Any] = {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = 0.0
            paragraphStyle.headIndent = 0.0
            paragraphStyle.tailIndent = 0.0
            paragraphStyle.lineSpacing = 4.0

            let font = UIFont.init(name: "TimesNewRomanPSMT", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
            return [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.link,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        }()

        let color = UIColor.label

        let attributes: [NSAttributedString.Key: Any] = {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = 0.0
            paragraphStyle.headIndent = 0.0
            paragraphStyle.tailIndent = 0.0
            paragraphStyle.lineSpacing = 4.0

            let font = UIFont.init(name: "TimesNewRomanPSMT", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
            return [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        }()

        let attributedString = NSMutableAttributedString(string: content, attributes: attributes)
        XMLRegexPatterns.parseSpecialFont(attributedString: attributedString, pattern: XMLRegexPatterns.linkText, attributes: linkAttributes)
        _attributedString = attributedString

        let width = viewWidth - leading - trailing
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        _textFrame = (attributedString.string as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        _textFrame.size.height += 5
        _textFrame.origin.x = leading
        _textFrame.origin.y = 5
    }
}
