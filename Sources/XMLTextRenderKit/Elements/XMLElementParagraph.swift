//
//  XMLElementParagraph.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit
import SWXMLHash

enum XMLImageData {
    case singleImage(frame: CGRect, image: UIImage)
    case multiImageDesc(frames: [CGRect], images: [UIImage], desc: XMLTextLayout, descFrame: CGRect)
}

final class XMLElementParagraph: XMLElementBase {
    let rawText: String
    let marked: Bool
    let indent: String?
    private var _attributedString: NSMutableAttributedString?
    private var _textLayout: XMLTextLayout?
    private var maxWidth = XMLRenderConfig.shared.maxRenderViewWidth
    private var xmlImages: XMLImageWrapper?

    // MARK: - Interface

    required init(xml: XMLIndexer) {
        rawText = xml.element!.text.trimmingCharacters(in: .whitespacesAndNewlines)
        marked = XMLElementBase.parseBoolValue(xml: xml, name: "marked") ?? false
        indent = XMLElementBase.parseStringValue(xml: xml, name: "indent")
        super.init(xml: xml)
        loadAttachment(xml: xml)
    }

    override var cellHeight: CGFloat {        
        let len1 = topPadding
        let len2 = textLayout?.textBoundingSize.height ?? 0.0
        let len3 = bottomPadding
        var height = len1 + len2 + len3
        if marked {
            print(len1, len2, len3)
        }
        if (xmlImages?.fullWidth ?? false) && !XMLRenderConfig.shared.isPad {
            height += _xmlImageFrame!.maxY
        }
        return height
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

    var labelFrame: CGRect {
        var y: CGFloat = topPadding
        if (xmlImages?.fullWidth ?? false) && !XMLRenderConfig.shared.isPad {
            y += _xmlImageFrame!.maxY
        }
        return CGRect(x: leading, y: y, width: maxWidth, height: textLayout!.textBoundingSize.height)
    }

    private var _xmlImageData: XMLImageData?
    private var _xmlImageFrame: CGRect?
    private var _excludeFrame: CGRect?

    var xmlImageData: XMLImageData? {
        if _xmlImageData == nil && xmlImages != nil {
            (_xmlImageData, _, _) = xmlImages!.getBriefImagesData()
        }
        return _xmlImageData
    }

    var xmlImagesDesc: NSAttributedString? {
        xmlImages?.attributedString
    }

    var xmlImageFrame: CGRect? {
        _xmlImageFrame
    }

    var excludeFrame: CGRect? {
        _excludeFrame
    }

    override func clearAttributedString() {
        _attributedString = nil
        _textLayout = nil
        xmlImages?.clearAttributedString()
    }

    func cleanImageData() {
        _xmlImageData = nil
    }

    // MARK: - Utils

    private lazy var regularTextAttributes = { [weak self] (headIndent: CGFloat, color: UIColor, underline: Bool) -> [NSAttributedString.Key: Any] in
        let fontSize = self?.fontSize ?? 17.0
        let regularFont = UIFont(name: "TimesNewRomanPSMT", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        let paragraph = NSMutableParagraphStyle()
        paragraph.firstLineHeadIndent = 0
        paragraph.headIndent = headIndent
        paragraph.tailIndent = (self?.xmlImages?.padTrailing ?? false) ? -20 : 0
        paragraph.lineSpacing = 8.0
        paragraph.alignment = self?.textAlignment ?? .left
        paragraph.paragraphSpacingBefore = 2
        paragraph.paragraphSpacing = 2
        let underlineStyle: NSUnderlineStyle = underline ? .single : []
        return [ .font: regularFont, .foregroundColor: color, .paragraphStyle: paragraph, .underlineStyle: underlineStyle.rawValue ]
    }

    private lazy var boldTextAttribtes = { [weak self] (headIndent: CGFloat) -> [NSAttributedString.Key: Any] in
        let fontSize = self?.fontSize ?? 17.0
        let boldFont = UIFont(name: "TimesNewRomanPS-BoldMT", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
        let paragraph = NSMutableParagraphStyle()
        paragraph.firstLineHeadIndent = 0
        paragraph.headIndent = headIndent
        paragraph.tailIndent = (self?.xmlImages?.padTrailing ?? false) ? -20 : 0
        paragraph.lineSpacing = 8.0
        paragraph.alignment = self?.textAlignment ?? .left
        paragraph.paragraphSpacingBefore = 2
        paragraph.paragraphSpacing = 2
        return [ .font: boldFont, .foregroundColor: UIColor.label, .paragraphStyle: paragraph ]
    }

    private lazy var italicTextAttribtes = { [weak self] (headIndent: CGFloat) -> [NSAttributedString.Key: Any] in
        let fontSize = self?.fontSize ?? 17.0
        let italicFont = UIFont(name: "TimesNewRomanPS-ItalicMT", size: fontSize) ?? UIFont.italicSystemFont(ofSize: fontSize)
        let paragraph = NSMutableParagraphStyle()
        paragraph.firstLineHeadIndent = 0
        paragraph.headIndent = headIndent
        paragraph.tailIndent = (self?.xmlImages?.padTrailing ?? false) ? -20 : 0
        paragraph.lineSpacing = 8.0
        paragraph.alignment = self?.textAlignment ?? .left
        paragraph.paragraphSpacingBefore = 2
        paragraph.paragraphSpacing = 2
        return [ .font: italicFont, .foregroundColor: UIColor.label, .paragraphStyle: paragraph ]
    }

    private func buildContent() {
        maxWidth = viewWidth - leading - trailing - 5.0
        var exclusionPaths: [UIBezierPath] = []
        if let xmlImages = xmlImages {
            (_xmlImageData, _xmlImageFrame, _excludeFrame) = xmlImages.getBriefImagesData()
            if !xmlImages.fullWidth || XMLRenderConfig.shared.isPad {
                if let excludeFrame = _excludeFrame {
                    exclusionPaths = [UIBezierPath(rect: excludeFrame)]
                }
            }
        }

        let indentWidth = calculateIndentWidth()

        let regularTextAttributes = self.regularTextAttributes(indentWidth, .label, false)
        let attributedString = NSMutableAttributedString(string: rawText, attributes: regularTextAttributes)
        XMLRegexPatterns.parseNewParagraphMark(attributedString: attributedString)

        let boldTextAttribtes = self.boldTextAttribtes(indentWidth)
        XMLRegexPatterns.parseSpecialFont(attributedString: attributedString, pattern: XMLRegexPatterns.boldText, attributes: boldTextAttribtes)

        let italicTextAttribtes = self.italicTextAttribtes(indentWidth)
        XMLRegexPatterns.parseSpecialFont(attributedString: attributedString, pattern: XMLRegexPatterns.italicText, attributes: italicTextAttribtes)

        let pasteActionTextAttributes = self.regularTextAttributes(indentWidth, XMLRenderConfig.shared.mainColor, true)
        XMLRegexPatterns.parsePasteActionText(attributedString: attributedString, attributes: pasteActionTextAttributes)

        let linkAttributes = self.regularTextAttributes(indentWidth, XMLRenderConfig.shared.mainColor, true)
        XMLRegexPatterns.parseLinkText(attributedString: attributedString, attributes: linkAttributes)

        _attributedString = attributedString
        let containerSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        _textLayout = XMLTextLayout(
            attributedString: attributedString,
            containerSize: containerSize,
            exclusionPaths: exclusionPaths,
            maximumNumberOfLines: 0
        )
    }

    private func loadAttachment(xml: XMLIndexer) {
        do {
            let data: XMLImageWrapper.XMLImages = try xml["p-images"].value()
            xmlImages = XMLImageWrapper(xmlImages: data)
        } catch { }
    }

    private func calculateIndentWidth() -> CGFloat {
        guard let indent = indent else {
            return 0
        }

        let regularTextAttributes = self.regularTextAttributes(0, .label, false)
        let attributedString = NSMutableAttributedString(string: indent, attributes: regularTextAttributes)

        let boldTextAttribtes = self.boldTextAttribtes(0)
        XMLRegexPatterns.parseSpecialFont(attributedString: attributedString, pattern: XMLRegexPatterns.boldText, attributes: boldTextAttribtes)

        let italicTextAttribtes = self.italicTextAttribtes(0)
        XMLRegexPatterns.parseSpecialFont(attributedString: attributedString, pattern: XMLRegexPatterns.italicText, attributes: italicTextAttribtes)

        let pasteActionTextAttributes = self.regularTextAttributes(0, XMLRenderConfig.shared.mainColor, true)
        XMLRegexPatterns.parsePasteActionText(attributedString: attributedString, attributes: pasteActionTextAttributes)

        let linkAttributes = self.regularTextAttributes(0, XMLRenderConfig.shared.mainColor, true)
        XMLRegexPatterns.parseLinkText(attributedString: attributedString, attributes: linkAttributes)

        return attributedString.boundingRect(with: .zero, options: .usesLineFragmentOrigin, context: nil).width
    }

    private static func getWidth(maxWidth width: CGFloat, inHeight height: CGFloat, excludeRect rect: CGRect?) -> CGFloat {
        guard let rect = rect else { return width }

        if (height + 10) < rect.minY || (height + 10) > rect.maxY {
            return width
        } else {
            return width - rect.width
        }
    }
}
