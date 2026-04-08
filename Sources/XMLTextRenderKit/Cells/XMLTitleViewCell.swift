//
//  XMLTitleViewCell.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit

final class XMLTitleViewCell: XMLViewCellBase {
    class InnerView: UIView {
        var attributedString: NSAttributedString?
        var textFrame: CGRect = .zero
        var dashPattern: [CGFloat]?
        var leading: CGFloat = 20
        var trailing: CGFloat = 20

        override func draw(_ rect: CGRect) {
            let color = UIColor.label
            if let attributedString = attributedString {
                attributedString.draw(in: textFrame)

                if let dashPattern = dashPattern {
                    let ctx = UIGraphicsGetCurrentContext()
                    ctx?.setStrokeColor(color.cgColor)
                    ctx?.setLineWidth(1.0)
                    ctx?.setAllowsAntialiasing(true)
                    ctx?.setLineDash(phase: 0.0, lengths: dashPattern)
                    ctx?.move(to: CGPoint(x: leading, y: height))
                    ctx?.addLine(to: CGPoint(x: rect.width - trailing, y: height))
                    ctx?.strokePath()
                }
            }
        }
    }

    private let view = InnerView()
    private var textData: XMLElementTitle?

    // MARK: - Interface

    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        view.backgroundColor = .clear
        contentView.addSubview(view)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var element: XMLElementBase? {
        didSet {
            guard let element = element as? XMLElementTitle else {
                let errMsg = "Wrong brief type for XMLTitleViewCell."
                // logger.error(errMsg)
                print(errMsg)
                return
            }

            backgroundColor = .clear
            contentView.backgroundColor = .clear

            textData = element
            view.attributedString = element.attributedString
            view.dashPattern = element.lineDashPattern
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
