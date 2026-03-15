//
//  XMLElementImages.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit
import SWXMLHash

final class XMLElementImages: XMLElementBase {
    struct XMLImage: XMLObjectDeserialization {
        let type: String
        let src: String
        let width: CGFloat?
        let height: CGFloat?
        let title: String?

        var image: UIImage? {
            switch type {
                case "base64":
                    let data = Data(base64Encoded: src)!
                    return UIImage(data: data)
                case "assets":
                    return UIImage(named: src)
                default:
                    return nil
            }
        }

        static func deserialize(_ node: XMLIndexer) throws -> XMLImage {
            let widthString: String? = node.value(ofAttribute: "width")
            let width: CGFloat?
            if widthString != nil {
                width = CGFloat(Double(widthString!)!)
            } else {
                width = nil
            }

            let heightString: String? = node.value(ofAttribute: "height")
            let height: CGFloat?
            if heightString != nil {
                height = CGFloat(Double(heightString!)!)
            } else {
                height = nil
            }

            return try XMLImage(type: node.value(ofAttribute: "type"), src: node.value(ofAttribute: "src"), width: width, height: height, title: node.value(ofAttribute: "title"))
        }
    }

    struct ImageMeta {
        let image: UIImage
        let imgFrame: CGRect
        let title: String?
        let titleFrame: CGRect?
    }

    let spacing: CGFloat?
    let xmlImages: [XMLImage]

    private var _images: [ImageMeta] = []
    private var _height: CGFloat = -1

    required init(xml: XMLIndexer) {
        if let spacingString = XMLElementBase.parseStringValue(xml: xml, name: "spacing") {
            spacing = CGFloat(Double(spacingString)!)
        } else {
            spacing = nil
        }

        do {
            xmlImages = try xml["p-image"].all.map { x in
                let img: XMLImage = try x.value()
                return img
            }
        } catch {
            xmlImages = []
        }

        super.init(xml: xml)

        topPadding = Self.parseCGFloatValue(xml: xml, name: "toppadding") ?? 0
        bottomPadding = Self.parseCGFloatValue(xml: xml, name: "bottompadding") ?? 10
    }

    var imageMetas: [ImageMeta] {
        if _images.count == 0 {
            buildContent()
        }

        return _images
    }

    override var cellHeight: CGFloat {
        if _height < 0 {
            buildContent()
        }

        return _height
    }

    override func clearAttributedString() { 
        _images.removeAll()
        _height = -1
    }

    private func buildContent() {
        let spacing = spacing ?? 20
        let extraWidth = leading + trailing


        var tmpImages: [UIImage?] = Array<UIImage?>.init(repeating: nil, count: xmlImages.count)

        var validCount = 0
        for i in 0 ..< xmlImages.count {
            let x = xmlImages[i]
            guard let image = x.image else {
                continue
            }
            tmpImages[i] = image
            validCount += 1
        }

        guard validCount > 0 else {
            return
        }

        let sumSpacing = spacing * CGFloat(validCount - 1)
        let imgWidth  = (viewWidth - extraWidth - sumSpacing) / CGFloat(validCount)
        var maxImgHeight: CGFloat = 0
        var xPos: CGFloat = leading
        var withTitle: Bool = false
        for i in 0 ..< xmlImages.count {
            let x = xmlImages[i]
            guard let image = tmpImages[i] else {
                continue
            }

            let imgHeight = image.size.height / image.size.width * imgWidth
            if imgHeight > maxImgHeight {
                maxImgHeight = imgHeight
            }
            let rect = CGRect(x: xPos, y: topPadding, width: imgWidth, height: imgHeight)
            let title = x.title
            let titleFrame: CGRect?
            if title != nil {
                titleFrame = CGRect(x: xPos, y: rect.maxY + 10, width: imgWidth, height: 24)
                withTitle = true
            } else {
                titleFrame = nil
            }

            let meta = ImageMeta(image: image, imgFrame: rect, title: title, titleFrame: titleFrame)
            _images.append(meta)

            xPos += imgWidth + spacing
        }

        _height = topPadding + maxImgHeight + bottomPadding
        if withTitle {
            _height += (10 + 24)
        }
    }
}
