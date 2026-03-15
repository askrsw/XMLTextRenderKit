//
//  XMLRegexPatterns.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import Foundation

class XMLRegexPatterns {
    static let boldText = { () -> NSRegularExpression in
        do {
            return try NSRegularExpression(pattern: "::b\\((.*?)\\)b::", options: .caseInsensitive)
        } catch {
            let errMsg = "Build NSRegularExpression(::b\\((.*?)\\)b::) error: \(error)"
            fatalError(errMsg)
        }
    }()

    static let italicText = { () -> NSRegularExpression in
        do {
            return try NSRegularExpression(pattern: "::i\\((.*?)\\)i::", options: .caseInsensitive)
        } catch {
            let errMsg = "Build NSRegularExpression(::i\\((.*?)\\)i::) error: \(error)"
            fatalError(errMsg)
        }
    }()

    static let linkText = { () -> NSRegularExpression in
        do {
            return try NSRegularExpression(pattern: "::link\\((.*?)\\)link::", options: .caseInsensitive)
        } catch {
            let errMsg = "Build NSRegularExpression(::link\\((.*?)\\)link::) error: \(error)"
            fatalError(errMsg)
        }
    }()

    static let pasteActionText = { () -> NSRegularExpression in
        do {
            return try NSRegularExpression(pattern: "::p\\((.*?)\\)p::", options: .caseInsensitive)
        } catch {
            let errMsg = "Build NSRegularExpression(::p\\((.*?)\\)p::) error: \(error)"
            fatalError(errMsg)
        }
    }()

    static func parseSpecialFont(attributedString: NSMutableAttributedString, pattern: NSRegularExpression, attributes: [NSAttributedString.Key: Any]) {
        let totalRange = attributedString.rangeOfAll
        let resultArray = pattern.matches(in: attributedString.string, options: .reportCompletion, range: totalRange)
        for iter in resultArray.reversed().enumerated() {
            let match = iter.element
            let full = match.range(at: 0)
            let first = match.range(at: 1)
            let text = (attributedString.string as NSString).substring(with: first) as String
            let attrText = NSAttributedString(string: text, attributes: attributes)
            attributedString.replaceCharacters(in: full, with: attrText)
        }
    }

    static func parsePasteActionText(attributedString: NSMutableAttributedString, attributes: [NSAttributedString.Key: Any]) {
        let totalRange = attributedString.rangeOfAll
        let resultArray = pasteActionText.matches(in: attributedString.string, options: .reportCompletion, range: totalRange)
        for iter in resultArray.reversed().enumerated() {
            let match = iter.element
            let full = match.range(at: 0)
            let first = match.range(at: 1)
            let text = (attributedString.string as NSString).substring(with: first) as String
            var mutableAttributes = attributes
            if let url = XMLTextAction.makePasteURL(text: text) {
                mutableAttributes[.link] = url
            }

            let attrText = NSAttributedString(string: text, attributes: mutableAttributes)
            attributedString.replaceCharacters(in: full, with: attrText)
        }
    }

    static func parseLinkText(attributedString: NSMutableAttributedString, attributes: [NSAttributedString.Key: Any]) {
        let totalRange = attributedString.rangeOfAll
        let resultArray = linkText.matches(in: attributedString.string, options: .reportCompletion, range: totalRange)
        for iter in resultArray.reversed().enumerated() {
            let match = iter.element
            let full = match.range(at: 0)
            let first = match.range(at: 1)
            let raw = (attributedString.string as NSString).substring(with: first) as String
            let parsed = LinkPayload.parseLinkPayload(raw)
            let text = parsed.displayText
            var mutableAttributes = attributes
            if let urlString = parsed.urlString, let url = URL(string: urlString) {
                mutableAttributes[.link] = url
            }
            let attrText = NSAttributedString(string: text, attributes: mutableAttributes)
            attributedString.replaceCharacters(in: full, with: attrText)
        }
    }

    static func parseNewParagraphMark(attributedString: NSMutableAttributedString) {
        let mark = "::(_n_)::"
        let results = attributedString.string.findAllIndex(mark)
        for range in results.reversed() {
            let attrNewLine = NSAttributedString(string: "\n")
            attributedString.replaceCharacters(in: range, with: attrNewLine)
        }
    }
}

fileprivate extension String {
    func findAllIndex(_ string:String) -> [NSRange] {
        var ranges:[NSRange] = []
        if string.elementsEqual("") {
            return ranges
        }
        let zero = self.startIndex
        let target = Array(string)
        let total = Array(self)

        let lenght = string.count
        var startPoint = 0

        while total.count >= startPoint + string.count {
            if total[startPoint] == target[0] {
                let startIndex = self.index(zero, offsetBy: startPoint)
                let endIndex = self.index(startIndex, offsetBy: lenght)
                let child = self[startIndex..<endIndex]
                if child.elementsEqual(string) {
                    ranges.append(NSRange.init(location: startPoint, length: lenght))
                    startPoint += lenght
                } else {
                    startPoint += 1
                }
            } else {
                startPoint += 1
            }
        }

        return ranges
    }
}

fileprivate struct LinkPayload {
    let displayText: String
    let urlString: String?

    static func parseLinkPayload(_ raw: String) -> LinkPayload {
        let chars = Array(raw)
        var index = 0
        var separatorIndex: Int?
        var isEscaped = false

        while index < chars.count {
            let ch = chars[index]
            if isEscaped {
                isEscaped = false
            } else if ch == "\\" {
                isEscaped = true
            } else if ch == "|" {
                separatorIndex = index
                break
            }
            index += 1
        }

        if let sep = separatorIndex {
            let left = String(chars[0..<sep])
            let right = String(chars[(sep + 1)..<chars.count])
            let display = unescapePipes(left)
            let url = unescapePipes(right)
            return LinkPayload(
                displayText: display.isEmpty ? url : display,
                urlString: url.isEmpty ? nil : url
            )
        }

        return LinkPayload(displayText: unescapePipes(raw), urlString: unescapePipes(raw))
    }

    static func unescapePipes(_ input: String) -> String {
        input.replacingOccurrences(of: "\\|", with: "|")
            .replacingOccurrences(of: "\\\\", with: "\\")
    }
}
