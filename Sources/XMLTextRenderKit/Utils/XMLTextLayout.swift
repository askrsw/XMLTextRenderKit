//
//  XMLTextLayout.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2026/3/6.
//

import UIKit

final class XMLTextLayout {
    let attributedString: NSAttributedString
    let containerSize: CGSize
    let exclusionPaths: [UIBezierPath]
    let maximumNumberOfLines: Int
    let textBoundingSize: CGSize

    init(
        attributedString: NSAttributedString,
        containerSize: CGSize,
        exclusionPaths: [UIBezierPath] = [],
        maximumNumberOfLines: Int = 0
    ) {
        self.attributedString = attributedString
        self.containerSize = containerSize
        self.exclusionPaths = exclusionPaths
        self.maximumNumberOfLines = maximumNumberOfLines
        self.textBoundingSize = Self.measure(
            attributedString: attributedString,
            containerSize: containerSize,
            exclusionPaths: exclusionPaths,
            maximumNumberOfLines: maximumNumberOfLines
        )
    }

    func apply(to textView: UITextView) {
        textView.textContainer.size = containerSize
        textView.textContainer.maximumNumberOfLines = maximumNumberOfLines
        textView.textContainer.exclusionPaths = exclusionPaths
        textView.attributedText = attributedString
    }

    private static func measure(
        attributedString: NSAttributedString,
        containerSize: CGSize,
        exclusionPaths: [UIBezierPath],
        maximumNumberOfLines: Int
    ) -> CGSize {
        guard containerSize.width > 0 else {
            return .zero
        }

        let textView = UITextView(frame: .zero, textContainer: nil)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.size = containerSize
        textView.textContainer.maximumNumberOfLines = maximumNumberOfLines
        textView.textContainer.exclusionPaths = exclusionPaths
        textView.attributedText = attributedString
        textView.frame = CGRect(origin: .zero, size: containerSize)
        let size = textView.sizeThatFits(CGSize(width: containerSize.width, height: .greatestFiniteMagnitude))
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
}
