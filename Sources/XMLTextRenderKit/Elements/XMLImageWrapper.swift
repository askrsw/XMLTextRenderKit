//
//  XMLImageWrapper.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit
import SWXMLHash

final class XMLImageWrapper {
    struct XMLImages: XMLObjectDeserialization {
        let allignment: String
        let maxWidth: CGFloat
        let imageNames: [String]
        let desc: String
        let heightDelta: CGFloat
        let ipadSide: String

        static func deserialize(_ node: XMLIndexer) throws -> XMLImages {
            let widthString: String = try node.value(ofAttribute: "maxWidth")
            let width: CGFloat = CGFloat(Double(widthString)!)
            var heightDelta: CGFloat = 0
            if node.element?.attribute(by: "heightDelta") != nil {
                let heightDeltaString: String = try node.value(ofAttribute: "heightDelta")
                heightDelta = CGFloat(Double(heightDeltaString)!)
            }
            var iPadSide = "right"
            if node.element?.attribute(by: "ipadSide") != nil {
                iPadSide = try node.value(ofAttribute: "ipadSide")
            }
            return try XMLImages(allignment: node.value(ofAttribute: "allignment"), maxWidth: width, imageNames: node["p-image"].value(), desc: node["p-desc"].value(), heightDelta: heightDelta, ipadSide: iPadSide)
        }
    }

    private let xmlImages: XMLImages
    private var _attributedString: NSAttributedString? = nil
    private var _textLayout: XMLTextLayout? = nil

    var fullWidth: Bool
    private var showDesc: Bool
    private var width: CGFloat

    // MARK: - Interface

    init(xmlImages data: XMLImages) {
        xmlImages = data
        if xmlImages.allignment == "full" {
            fullWidth = true
            showDesc = true
            if !XMLRenderConfig.shared.isPad {
                width = XMLRenderConfig.shared.maxRenderViewWidth - 40
            } else {
                width = XMLRenderConfig.shared.maxRenderViewWidth * 0.5
            }
        } else {
            fullWidth = false
            showDesc = false
            if !XMLRenderConfig.shared.isPad {
                width = (XMLRenderConfig.shared.maxRenderViewWidth - 20) * 0.5
            } else {
                width = xmlImages.maxWidth
            }
        }
    }

    var padding: CGFloat = 10.0
    var imageSpaceing: CGFloat = 10.0

    var attributedString: NSAttributedString {
        if _attributedString == nil {
            buildAttributedString()
        }
        return _attributedString!
    }

    var textLayout: XMLTextLayout {
        if _textLayout == nil {
            _textLayout = makeTextLayout(width: width)
        }
        return _textLayout!
    }

    var padTrailing: Bool {
        if XMLRenderConfig.shared.isPad {
            return xmlImages.allignment == "right" || xmlImages.ipadSide != "left"
        }

        return false
    }

    func clearAttributedString() {
        _attributedString = nil
        _textLayout = nil
    }

    func getBriefImagesData() -> (XMLImageData, CGRect, CGRect) {
        let (images, frames) = makeImages()
        if fullWidth {
            let textLayout = self.textLayout
            var excludeFrame: CGRect = .zero
            let textLayoutFrame = CGRect(x: padding, y: padding + frames.first!.height + 10.0, width: textLayout.textBoundingSize.width, height: textLayout.textBoundingSize.height)
            var x = XMLRenderConfig.shared.maxRenderViewWidth - 20.0 - width
            var excludeX: CGFloat = x - 20
            var widthDelta: CGFloat = 30
            if XMLRenderConfig.shared.isPad && xmlImages.ipadSide == "left" {
                x = 20
                excludeX = 0.0
                widthDelta = 20
            }
            let blockFrame = CGRect(x: x, y: 10, width: width, height: padding + frames.first!.height + 10 + textLayout.textBoundingSize.height + 10)
            excludeFrame = CGRect(x: excludeX, y: 0, width: width + widthDelta, height: blockFrame.height + xmlImages.heightDelta)
            return (XMLImageData.multiImageDesc(frames: frames, images: images, desc: textLayout, descFrame: textLayoutFrame), blockFrame, excludeFrame)
        } else {
            if XMLRenderConfig.shared.isPad {
                var blockFrame: CGRect = .zero
                var excludeFrame: CGRect = .zero
                if xmlImages.allignment == "left" {
                    blockFrame = CGRect(x: 20, y: 10, width: width, height: padding + frames.first!.height + padding)
                    excludeFrame = CGRect(x: 0, y: 0, width: width + 20, height: blockFrame.height + xmlImages.heightDelta)
                } else {
                    blockFrame = CGRect(x: XMLRenderConfig.shared.maxRenderViewWidth - 20.0 - width, y: 10, width: width, height: padding + frames.first!.height + padding)
                    excludeFrame = CGRect(x: blockFrame.origin.x - 30, y: 0, width: width + 40, height: blockFrame.height + xmlImages.heightDelta)
                }
                return (XMLImageData.singleImage(frame: frames.first!, image: images.first!), blockFrame, excludeFrame)
            } else {
                var blockFrame: CGRect = .zero
                var excludeFrame: CGRect = .zero
                if xmlImages.allignment == "left" {
                    blockFrame = CGRect(x: 20, y: 15, width: width, height: padding + frames.first!.height + padding)
                    excludeFrame = CGRect(x: 0, y: 5, width: width + 10, height: blockFrame.height)
                } else {
                    blockFrame = CGRect(x: XMLRenderConfig.shared.maxRenderViewWidth - 20.0 - width, y: 15.0, width: width, height: padding + frames.first!.height + padding)
                    excludeFrame = CGRect(x: XMLRenderConfig.shared.maxRenderViewWidth - 40 - width, y: 5, width: blockFrame.width, height: blockFrame.height)
                }
                return (XMLImageData.singleImage(frame: frames.first!, image: images.first!), blockFrame, excludeFrame)
            }
        }
    }

    // MARK: - Utils

    private func makeImages() -> ([UIImage], [CGRect]) {
        var images = [UIImage]()
        var rects = [CGRect]()
        var sizes = [CGSize]()

        var widthSum: CGFloat = 0
        for name in xmlImages.imageNames {
            let image = UIImage(named: name)!
            sizes.append(image.size)
            images.append(image)
            widthSum += image.size.width
        }

        let imgWidth = width - padding * 2.0 - imageSpaceing * CGFloat(images.count - 1)
        var xPos = padding
        for size in sizes {
            let sWidth = imgWidth * (size.width / widthSum)
            let sHeight = sWidth / size.width * size.height
            let frame = CGRect(x: xPos , y: padding, width: sWidth, height: sHeight)
            rects.append(frame)
            xPos += imageSpaceing + sWidth
        }

        return (images, rects)
    }

    private func makeTextLayout(width: CGFloat) -> XMLTextLayout {
        let containerSize = CGSize(width: width - padding * 2.0, height: .greatestFiniteMagnitude)
        return XMLTextLayout(attributedString: attributedString, containerSize: containerSize)
    }

    private func buildAttributedString() {
        let color = UIColor.label

        let regularTextAttributes: [NSAttributedString.Key: Any] = {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 5.0
            paragraph.alignment = .left
            return [
                NSAttributedString.Key.font: UIFont.init(name: "TimesNewRomanPSMT", size: 18) ?? UIFont.systemFont(ofSize: 18),
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.paragraphStyle: paragraph
            ]
        }()

        let italicTextAttributes: [NSAttributedString.Key: Any] = {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 5.0
            paragraph.alignment = .left
            return [
                NSAttributedString.Key.font: UIFont.init(name: "TimesNewRomanPS-ItalicMT", size: 18) ?? UIFont.italicSystemFont(ofSize: 18),
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.paragraphStyle: paragraph
            ]
        }()

        let attributedString = NSMutableAttributedString(string: xmlImages.desc, attributes: regularTextAttributes)
        XMLRegexPatterns.parseSpecialFont(attributedString: attributedString, pattern: XMLRegexPatterns.italicText, attributes: italicTextAttributes)
        _attributedString = attributedString.copy() as? NSAttributedString
    }
}
