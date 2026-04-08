//
//  XMLInlineNode.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2026/4/7.
//

import Foundation
import SWXMLHash

indirect enum XMLInlineNode {
    case text(String)
    case bold([XMLInlineNode])
    case italic([XMLInlineNode])
    case link(urlString: String?, children: [XMLInlineNode])
    case lineBreak
}

struct XMLInlineTextStyle {
    var isBold = false
    var isItalic = false
    var isLink = false
    var url: URL?
}

struct XMLInlineRenderer {
    let attributesForStyle: (XMLInlineTextStyle) -> [NSAttributedString.Key: Any]

    func render(nodes: [XMLInlineNode]) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        append(nodes: nodes, style: XMLInlineTextStyle(), to: attributedString)
        return attributedString
    }

    private func append(nodes: [XMLInlineNode], style: XMLInlineTextStyle, to attributedString: NSMutableAttributedString) {
        for node in nodes {
            switch node {
                case .text(let text):
                    guard !text.isEmpty else { continue }
                    attributedString.append(NSAttributedString(string: text, attributes: attributesForStyle(style)))
                case .lineBreak:
                    attributedString.append(NSAttributedString(string: "\n", attributes: attributesForStyle(style)))
                case .bold(let children):
                    var nestedStyle = style
                    nestedStyle.isBold = true
                    append(nodes: children, style: nestedStyle, to: attributedString)
                case .italic(let children):
                    var nestedStyle = style
                    nestedStyle.isItalic = true
                    append(nodes: children, style: nestedStyle, to: attributedString)
                case .link(let urlString, let children):
                    var nestedStyle = style
                    nestedStyle.isLink = true
                    nestedStyle.url = urlString.flatMap(URL.init(string:))
                    append(nodes: children, style: nestedStyle, to: attributedString)
            }
        }
    }
}

enum XMLInlineNodeParser {
    static func parseNodes(from xml: XMLIndexer) -> [XMLInlineNode] {
        guard
            let element = xml.element,
            let innerXML = innerXML(from: String(describing: element))
        else {
            return []
        }

        let trimmed = innerXML.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return []
        }

        let parser = _XMLInlineXMLParser()
        return parser.parse(innerXML: trimmed)
    }

    private static func innerXML(from elementDescription: String) -> String? {
        guard
            let start = elementDescription.firstIndex(of: ">"),
            let endRange = elementDescription.range(of: "</", options: .backwards),
            start < endRange.lowerBound
        else {
            return nil
        }

        let innerStart = elementDescription.index(after: start)
        return String(elementDescription[innerStart..<endRange.lowerBound])
    }
}

private final class _XMLInlineXMLParser: NSObject, XMLParserDelegate {
    private enum NodeKind {
        case root
        case bold
        case italic
        case link(String?)
    }

    private struct NodeBuilder {
        let kind: NodeKind
        var children: [XMLInlineNode]
    }

    private var stack: [NodeBuilder] = []

    func parse(innerXML: String) -> [XMLInlineNode] {
        let wrappedXML = "<root>\(innerXML)</root>"
        guard let data = wrappedXML.data(using: .utf8) else {
            return [.text(innerXML)]
        }

        stack = [NodeBuilder(kind: .root, children: [])]
        let parser = XMLParser(data: data)
        parser.delegate = self
        let success = parser.parse()
        guard success else {
            return [.text(innerXML)]
        }

        return stack.first?.children ?? [.text(innerXML)]
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        append(.text(string))
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard let string = String(data: CDATABlock, encoding: .utf8) else {
            return
        }
        append(.text(string))
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        switch elementName.lowercased() {
            case "root":
                break
            case "b":
                stack.append(NodeBuilder(kind: .bold, children: []))
            case "i":
                stack.append(NodeBuilder(kind: .italic, children: []))
            case "a":
                stack.append(NodeBuilder(kind: .link(attributeDict["href"]), children: []))
            case "br":
                append(.lineBreak)
            default:
                break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName.lowercased() {
            case "b", "i", "a":
                guard stack.count > 1 else { return }
                let builder = stack.removeLast()
                switch builder.kind {
                    case .bold:
                        append(.bold(builder.children))
                    case .italic:
                        append(.italic(builder.children))
                    case .link(let urlString):
                        append(.link(urlString: urlString, children: builder.children))
                    case .root:
                        break
                }
            default:
                break
        }
    }

    private func append(_ node: XMLInlineNode) {
        guard !stack.isEmpty else { return }

        if case .text(let text) = node,
           case .text(let previous)? = stack[stack.count - 1].children.last {
            stack[stack.count - 1].children[stack[stack.count - 1].children.count - 1] = .text(previous + text)
        } else {
            stack[stack.count - 1].children.append(node)
        }
    }
}
