//
//  XMLElementList.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2026/4/7.
//

import UIKit
import SWXMLHash

final class IconRender {
    static let shared = IconRender()

    private init() { }

    func dotImage(size: CGSize, color: UIColor) -> UIImage? {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            let cgContext = context.cgContext
            cgContext.setFillColor(color.cgColor)

            let radius = min(size.width, size.height) / 5
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            cgContext.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
            cgContext.fillPath()
        }
    }
}

private struct XMLListItem {
    let rawText: String
    let inlineNodes: [XMLInlineNode]
}

final class XMLElementList: XMLElementBase {
    enum ListStyle: String {
        case bullet
        case number
    }

    let listStyle: ListStyle
    let startIndex: Int
    let markerColor: UIColor
    let markerGap: CGFloat
    let markerSize: CGFloat
    let numberFontSize: CGFloat
    private let items: [XMLListItem]

    private var _attributedString: NSAttributedString?
    private var _textLayout: XMLTextLayout?
    private var maxWidth = XMLRenderConfig.shared.maxRenderViewWidth

    required init(xml: XMLIndexer) {
        let styleRaw = XMLElementBase.parseStringValue(xml: xml, name: "style")?.lowercased() ?? "bullet"
        listStyle = ListStyle(rawValue: styleRaw) ?? .bullet
        startIndex = XMLElementBase.parseIntValue(xml: xml, name: "start") ?? 1
        markerColor = UIColor.xmlColor(from: XMLElementBase.parseStringValue(xml: xml, name: "marker-color")) ?? .label
        markerGap = max(0, XMLElementBase.parseCGFloatValue(xml: xml, name: "marker-gap") ?? 8)
        markerSize = XMLElementBase.parseCGFloatValue(xml: xml, name: "marker-size") ?? 0
        numberFontSize = XMLElementBase.parseCGFloatValue(xml: xml, name: "number-font-size") ?? 0
        items = xml.children.compactMap { child in
            guard child.element?.name == "p-item" else {
                return nil
            }
            return XMLListItem(
                rawText: child.element?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                inlineNodes: XMLInlineNodeParser.parseNodes(from: child)
            )
        }
        super.init(xml: xml)
    }

    override var attributedString: NSAttributedString? {
        if _attributedString == nil {
            buildContent()
        }
        return _attributedString
    }

    override var textLayout: XMLTextLayout? {
        if _textLayout == nil {
            buildContent()
        }
        return _textLayout
    }

    override var cellHeight: CGFloat {
        topPadding + (textLayout?.textBoundingSize.height ?? 0) + bottomPadding
    }

    var labelFrame: CGRect {
        CGRect(x: leading, y: topPadding, width: maxWidth, height: textLayout?.textBoundingSize.height ?? 0)
    }

    override func clearAttributedString() {
        _attributedString = nil
        _textLayout = nil
    }

    var itemTexts: [String] {
        items.map(\.rawText)
    }

    private lazy var textAttributes = { [weak self] (
        color: UIColor,
        underline: Bool,
        isBold: Bool,
        isItalic: Bool,
        paragraphStyle: NSParagraphStyle?
    ) -> [NSAttributedString.Key: Any] in
        let fontSize = self?.fontSize ?? 17.0
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

        let underlineStyle: NSUnderlineStyle = underline ? .single : []
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .underlineStyle: underlineStyle.rawValue
        ]
        if let paragraphStyle {
            attributes[.paragraphStyle] = paragraphStyle
        }
        return attributes
    }

    private func buildContent() {
        maxWidth = viewWidth - leading - trailing - 5.0
        let attributedString = NSMutableAttributedString()

        for (index, item) in items.enumerated() {
            if index > 0 {
                attributedString.append(NSAttributedString(string: "\n"))
            }

            let markerMetrics = markerMetrics()
            let paragraphStyle = makeParagraphStyle(headIndent: markerMetrics.headIndent)
            let itemText = buildItemAttributedString(item: item, paragraphStyle: paragraphStyle)
            let markerString = buildMarkerAttributedString(for: index, metrics: markerMetrics, paragraphStyle: paragraphStyle)
            markerString.append(itemText)
            attributedString.append(markerString)
        }

        _attributedString = attributedString
        _textLayout = XMLTextLayout(
            attributedString: attributedString,
            containerSize: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            maximumNumberOfLines: 0
        )
    }

    private func buildItemAttributedString(item: XMLListItem, paragraphStyle: NSParagraphStyle) -> NSAttributedString {
        let nodes = item.inlineNodes.isEmpty ? [.text(item.rawText)] : item.inlineNodes
        let renderer = XMLInlineRenderer { [weak self] style in
            let color = style.isLink ? XMLRenderConfig.shared.mainColor : UIColor.label
            var attributes = self?.textAttributes(color, style.isLink, style.isBold, style.isItalic, paragraphStyle) ?? [:]
            if let url = style.url {
                attributes[.link] = url
            }
            return attributes
        }
        let attributedString = renderer.render(nodes: nodes)
        if attributedString.length == 0 {
            attributedString.append(NSAttributedString(
                string: item.rawText,
                attributes: textAttributes(.label, false, false, false, paragraphStyle)
            ))
        }

        let boldAttributes = textAttributes(.label, false, true, false, paragraphStyle)
        XMLRegexPatterns.parseSpecialFont(attributedString: attributedString, pattern: XMLRegexPatterns.boldText, attributes: boldAttributes)

        let italicAttributes = textAttributes(.label, false, false, true, paragraphStyle)
        XMLRegexPatterns.parseSpecialFont(attributedString: attributedString, pattern: XMLRegexPatterns.italicText, attributes: italicAttributes)

        let linkAttributes = textAttributes(XMLRenderConfig.shared.mainColor, true, false, false, paragraphStyle)
        XMLRegexPatterns.parsePasteActionText(attributedString: attributedString, attributes: linkAttributes)
        XMLRegexPatterns.parseLinkText(attributedString: attributedString, attributes: linkAttributes)
        XMLRegexPatterns.parseNewParagraphMark(attributedString: attributedString)

        return attributedString
    }

    private func buildMarkerAttributedString(for index: Int, metrics: MarkerMetrics, paragraphStyle: NSParagraphStyle) -> NSMutableAttributedString {
        switch listStyle {
            case .bullet:
                let markerDimension = resolvedMarkerSize
                let markerSize = CGSize(width: markerDimension, height: markerDimension)
                let attachment = NSTextAttachment()
                attachment.image = IconRender.shared.dotImage(size: markerSize, color: markerColor)
                let font = textAttributes(.label, false, false, false, nil)[.font] as? UIFont
                let yOffset = ((font?.capHeight ?? markerSize.height) - markerSize.height) / 2
                attachment.bounds = CGRect(x: 0, y: yOffset, width: markerSize.width, height: markerSize.height)
                let attributedString = NSMutableAttributedString(attachment: attachment)
                attributedString.addAttributes(
                    textAttributes(markerColor, false, false, false, paragraphStyle),
                    range: NSRange(location: 0, length: attributedString.length)
                )
                attributedString.append(NSAttributedString(string: metrics.spacingString, attributes: textAttributes(markerColor, false, false, false, paragraphStyle)))
                return attributedString
            case .number:
                let attributedString = NSMutableAttributedString(
                    string: "\(startIndex + index).",
                    attributes: markerTextAttributes()
                )
                attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: attributedString.rangeOfAll)
                attributedString.append(NSAttributedString(string: metrics.spacingString, attributes: textAttributes(markerColor, false, false, false, paragraphStyle)))
                return attributedString
        }
    }

    private func markerMetrics() -> MarkerMetrics {
        switch listStyle {
            case .bullet:
                let markerWidth = resolvedMarkerSize
                return MarkerMetrics(headIndent: markerWidth + markerGap, spacingString: "\t")
            case .number:
                let sampleText = widthSampleText()
                let markerWidth = NSAttributedString(
                    string: sampleText,
                    attributes: markerTextAttributes()
                )
                .boundingRect(with: .zero, options: .usesLineFragmentOrigin, context: nil).width
                return MarkerMetrics(headIndent: ceil(markerWidth) + markerGap, spacingString: "\t")
        }
    }

    private func makeParagraphStyle(headIndent: CGFloat) -> NSParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.firstLineHeadIndent = 0
        paragraph.headIndent = headIndent
        paragraph.tailIndent = 0
        paragraph.lineSpacing = 8.0
        paragraph.alignment = textAlignment
        paragraph.paragraphSpacingBefore = 2
        paragraph.paragraphSpacing = 6
        paragraph.tabStops = [NSTextTab(textAlignment: .left, location: headIndent)]
        paragraph.defaultTabInterval = headIndent
        return paragraph
    }

    private func widthSampleText() -> String {
        let maxValue = max(startIndex + items.count - 1, startIndex)
        let digitCount = String(maxValue).count
        let digits = String(repeating: "9", count: min(max(digitCount, 1), 3))
        return "\(digits)."
    }

    private func markerTextAttributes() -> [NSAttributedString.Key: Any] {
        let font = markerFont()
        return [
            .font: font,
            .foregroundColor: markerColor
        ]
    }

    private func markerFont() -> UIFont {
        let resolvedSize: CGFloat = {
            switch listStyle {
                case .bullet:
                    return resolvedMarkerSize
                case .number:
                    return resolvedNumberFontSize
            }
        }()
        return UIFont(name: "TimesNewRomanPSMT", size: resolvedSize) ?? UIFont.systemFont(ofSize: resolvedSize)
    }

    private var resolvedMarkerSize: CGFloat {
        markerSize > 0 ? markerSize : (fontSize * 0.9)
    }

    private var resolvedNumberFontSize: CGFloat {
        numberFontSize > 0 ? numberFontSize : fontSize
    }
}

private struct MarkerMetrics {
    let headIndent: CGFloat
    let spacingString: String
}
