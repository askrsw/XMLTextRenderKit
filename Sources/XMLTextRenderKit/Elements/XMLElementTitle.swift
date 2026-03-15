//
//  XMLElementTitle.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit
import SWXMLHash

final class XMLElementTitle: XMLElementBase {
    private let title: String
    private let level: Int
    private let underline: Bool

    private var _textFrame: CGRect = .zero
    private var _attributedString: NSAttributedString?

    // MARK: - Interface

    required init(xml: XMLIndexer) {
        title = xml.element!.text
        level = XMLElementBase.parseIntValue(xml: xml, name: "level") ?? 2
        underline = XMLElementBase.parseBoolValue(xml: xml, name: "underline") ?? true
        super.init(xml: xml)

        switch level {
            case 1:
                if hasTopPaddingAttribute == false { topPadding = 20 }
                if hasBottomPaddingAttribute == false { bottomPadding = 10 }
                if hasFontSizeAttribute == false { fontSize = 26 }
            case 2:
                if hasTopPaddingAttribute == false { topPadding = 15 }
                if hasBottomPaddingAttribute == false { bottomPadding = 8 }
                if hasFontSizeAttribute == false { fontSize = 22 }
            case 3:
                if hasTopPaddingAttribute == false { topPadding = 15 }
                if hasBottomPaddingAttribute == false { bottomPadding = 4 }
                if hasFontSizeAttribute == false { fontSize = 20 }
            case 4:
                if hasTopPaddingAttribute == false { topPadding = 15 }
                if hasBottomPaddingAttribute == false { bottomPadding = 4 }
                if hasFontSizeAttribute == false { fontSize = 18 }
            default:
                break
        }
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

        return _textFrame.maxY + topPadding + bottomPadding
    }

    var drawBottomLime: Bool {
        switch level {
            default: return true
        }
    }

    var lineDashPattern: [CGFloat]? {
        if underline == false {
            return nil
        }
        switch level {
            case 1: return [10, 0]
            case 2: return [15, 7]
            case 3: return [4, 2]
            case 4: return [1, 1]
            default: return nil
        }
    }

    var textFrame: CGRect {
        if _attributedString == nil {
            buildAttributedString()
        }
        return _textFrame
    }

    override func clearAttributedString() {
        _attributedString = nil
    }

    // MARK: - Utils

    private func buildAttributedString() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0.0
        paragraphStyle.headIndent = 0.0
        paragraphStyle.tailIndent = 0.0
        paragraphStyle.lineSpacing = 8.0
        paragraphStyle.alignment = textAlignment

        let color = UIColor.label

        // TimesNewRomanPS-BoldMT, Georgia-Bold
        let font = UIFont.init(name: "TimesNewRomanPS-BoldMT", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
        let titleAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]

        let attributedString = NSMutableAttributedString(string: title, attributes: titleAttributes)
        let width = viewWidth - leading - trailing
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        _textFrame = (title as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: titleAttributes, context: nil)
        _textFrame.size.height += 6
        _textFrame.origin.x = leading

        _attributedString = attributedString
    }
}
