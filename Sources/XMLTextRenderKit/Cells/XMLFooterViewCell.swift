//
//  XMLFooterViewCell.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/28.
//

import UIKit

final class XMLFooterViewCell: XMLViewCellBase {
    class InnerView: UIView {
        var attributedString: NSAttributedString?
        var textFrame: CGRect = .zero
        var leading: CGFloat = 20
        var trailing: CGFloat = 20

        override func draw(_ rect: CGRect) {
            let color = UIColor.label
            let ctx = UIGraphicsGetCurrentContext()
            ctx?.setStrokeColor(color.cgColor)
            ctx?.setLineWidth(1.0)
            ctx?.move(to: CGPoint(x: leading, y: 0))
            ctx?.addLine(to: CGPoint(x: rect.width - trailing, y: 0))
            ctx?.strokePath()

            attributedString?.draw(in: textFrame)
        }
    }

    private let view = InnerView()
    private var textData: XMLElementFooter?

    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(view)
        view.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var element: XMLElementBase? {
        didSet {
            guard let element = element as? XMLElementFooter else {
                let errMsg = "Wrong brief type for BriefFooterViewCell."
                print(errMsg)
                return
            }

            if element.blockSection {
                backgroundColor = XMLRenderConfig.shared.textInfoBackgroundColor
            } else {
                backgroundColor = .clear
            }

            textData = element
            view.attributedString = element.attributedString
            view.textFrame = element.textFrame
            view.leading = element.leading
            view.trailing = element.trailing

            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let data = textData {
            view.frame = CGRect(x: 0, y: data.topPadding, width: width, height: height - data.topPadding - data.bottomPadding)
            view.setNeedsDisplay()
        }
    }
}
