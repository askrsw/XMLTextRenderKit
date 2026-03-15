//
//  XMLParagraphViewCell.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit

final class XMLParagraphViewCell: XMLViewCellBase {
    private let textView = XMLTextView()
    private let xmlImageView = XMLImageView()
    private var textData: XMLElementParagraph?
    private var textLayout: XMLTextLayout?

    // MARK: - Interface

    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(textView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var element: XMLElementBase? {
        didSet {
            guard let element = element as? XMLElementParagraph else {
                let errMsg = "Wrong brief type for BriefParagraphViewCell."
                print(errMsg)
                return
            }
            textData = element
            textLayout = textData?.textLayout

            if element.blockSection {
                backgroundColor = XMLRenderConfig.shared.textInfoBackgroundColor
            } else {
                backgroundColor = .clear
            }

            if let xmlImageData = element.xmlImageData {
                xmlImageView.data = xmlImageData
                xmlImageView.attributedDesc = element.xmlImagesDesc
                if xmlImageView.superview == nil {
                    contentView.addSubview(xmlImageView)
                }
                element.cleanImageData()
            } else {
                xmlImageView.removeFromSuperview()
            }

            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let textData = textData {
            textView.frame = textData.labelFrame
            textView.apply(layout: textLayout)
            if let frame = textData.xmlImageFrame {
                xmlImageView.frame = frame
                xmlImageView.setNeedsDisplay()
            }

        }
    }
}
