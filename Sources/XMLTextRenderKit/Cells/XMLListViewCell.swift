//
//  XMLListViewCell.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2026/4/7.
//

import UIKit

final class XMLListViewCell: XMLViewCellBase {
    private let textView = XMLTextView()
    private var textData: XMLElementList?
    private var textLayout: XMLTextLayout?

    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var element: XMLElementBase? {
        didSet {
            guard let element = element as? XMLElementList else {
                let errMsg = "Wrong brief type for XMLListViewCell."
                print(errMsg)
                return
            }

            textData = element
            textLayout = element.textLayout
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let textData = textData {
            textView.frame = textData.labelFrame
            textView.apply(layout: textLayout)
        }
    }
}
