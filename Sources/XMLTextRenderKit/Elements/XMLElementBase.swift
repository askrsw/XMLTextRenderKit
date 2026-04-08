//
//  XMLElementBase.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit
import SWXMLHash

class XMLElementBase {
    var topPadding: CGFloat
    var bottomPadding: CGFloat
    var leading: CGFloat
    var trailing: CGFloat
    var fontSize: CGFloat
    var textAlignment: NSTextAlignment

    private(set) var hasTopPaddingAttribute: Bool = false
    private(set) var hasBottomPaddingAttribute: Bool = false
    private(set) var hasLeadingAttribute: Bool = false
    private(set) var hasTrailingAttribute: Bool = false
    private(set) var hasFontSizeAttribute: Bool = false
    private(set) var hasAlignmentAttribute: Bool = false

    private(set) var id: String?

    required init(xml: XMLIndexer) {
        id = XMLElementBase.parseStringValue(xml: xml, name: "id")

        if let parsedTopPadding = Self.parseCGFloatValue(xml: xml, name: "toppadding") {
            topPadding = parsedTopPadding
            hasTopPaddingAttribute = true
        } else {
            topPadding = 8
        }
        if let parsedBottomPadding = Self.parseCGFloatValue(xml: xml, name: "bottompadding") {
            bottomPadding = parsedBottomPadding
            hasBottomPaddingAttribute = true
        } else {
            bottomPadding = 8
        }
        if let parsedLeading = Self.parseCGFloatValue(xml: xml, name: "leading") {
            leading = parsedLeading
            hasLeadingAttribute = true
        } else {
            leading = 20
        }
        if let parsedTrailing = Self.parseCGFloatValue(xml: xml, name: "trailing") {
            trailing = parsedTrailing
            hasTrailingAttribute = true
        } else {
            trailing = 20
        }
        if let parsedFontSize = Self.parseCGFloatValue(xml: xml, name: "fontsize") {
            fontSize = parsedFontSize
            hasFontSizeAttribute = true
        } else {
            fontSize = 17
        }
        if let parsedAlignment = Self.parseTextAlignment(xml: xml, name: "align") {
            textAlignment = parsedAlignment
            hasAlignmentAttribute = true
        } else {
            textAlignment = .left
        }
    }

    init(id: String?) {
        self.id = id
        self.topPadding = 8
        self.bottomPadding = 8
        self.leading = 20
        self.trailing = 20
        self.fontSize = 17
        self.textAlignment = .left
    }

    final var className: String {
        NSStringFromClass(Self.self)
    }

    var flattenContents: [XMLElementBase] {
        [ self ]
    }

    var cellHeight: CGFloat {
        0.0
    }

    var attributedString: NSAttributedString? {
        nil
    }

    var textLayout: XMLTextLayout? {
        nil
    }

    var viewWidth: CGFloat = 0 {
        didSet {
            if viewWidth != oldValue {
                clearAttributedString()
            }
        }
    }

    func clearAttributedString() {
        fatalError("Sub class must implement this method.")
    }
}

extension XMLElementBase {
    static func parseCGFloatValue(xml: XMLIndexer, name: String) -> CGFloat? {
        if xml.element?.attribute(by: name) != nil {
            do {
                let string: String = try xml.value(ofAttribute: name)
                if let v = Float(string) {
                    return CGFloat(v)
                }
            } catch { }
        }
        return nil
    }

    static func parseIntValue(xml: XMLIndexer, name: String) -> Int? {
        if xml.element?.attribute(by: name) != nil {
            do {
                let string: String = try xml.value(ofAttribute: name)
                return Int(string)
            } catch { }
        }
        return nil
    }

    static func parseStringValue(xml: XMLIndexer, name: String) -> String? {
        if xml.element?.attribute(by: name) != nil {
            do {
                let string: String = try xml.value(ofAttribute: name)
                return string
            } catch { }
        }
        return nil
    }

    static func parseBoolValue(xml: XMLIndexer, name: String) -> Bool? {
        if xml.element?.attribute(by: name) != nil {
            do {
                let string: String = try xml.value(ofAttribute: name)
                return Bool(string)
            } catch { }
        }
        return nil
    }

    static func parseTextAlignment(xml: XMLIndexer, name: String) -> NSTextAlignment? {
        guard xml.element?.attribute(by: name) != nil else {
            return nil
        }
        do {
            let raw: String = try xml.value(ofAttribute: name)
            switch raw.lowercased() {
                case "left": return .left
                case "center": return .center
                case "right": return .right
                case "justify", "justified": return .justified
                default: return nil
            }
        } catch { }
        return nil
    }
}
