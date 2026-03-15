//
//  XMLImageFullScreenView.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit

final class XMLImageFullScreenView: UIView {
    let image: UIImage
    let imageFrame: CGRect
    let desc: NSAttributedString
    let blurView: UIVisualEffectView
    let imageView: UIImageView
    let textView: XMLTextView

    // MARK: - Interface

    init(image img: UIImage, imageFrame imgRect: CGRect,  desc str: NSAttributedString) {
        image = img
        imageFrame = imgRect
        desc = str

        let style: UIBlurEffect.Style = UIColor.isDarkMode ? .systemChromeMaterialDark : .systemChromeMaterialLight
        let blur = UIBlurEffect(style: style)
        blurView = UIVisualEffectView(effect: blur)

        imageView = UIImageView()

        textView = XMLTextView()

        super.init(frame: CGRect(origin: .zero, size: UIScreen.main.bounds.size))

        backgroundColor = .clear

        guard let window = UIWindow.currentKeyWindow else {
            fatalError("Can not get window instance!")
        }
        window.addSubview(self)

        blurView.frame = bounds
        blurView.alpha = 0.0
        addSubview(blurView)

        imageView.image = image
        imageView.frame = imageFrame
        imageView.alpha = 0.0
        addSubview(imageView)

        let (imgDestRect, labelRect) = rekonViewRect()

        textView.frame = labelRect
        textView.apply(layout: XMLTextLayout(attributedString: desc, containerSize: labelRect.size))
        textView.alpha = 0.0
        addSubview(textView)

        UIView.animate(withDuration: 0.35, animations: {
            self.blurView.alpha = 0.975
            self.imageView.frame = imgDestRect
            self.imageView.alpha = 1.0
        }, completion: { _ in
            self.textView.alpha = 1.0
        })

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Utils

    @objc
    private func tapAction(_ tap: UITapGestureRecognizer) {
        textView.removeFromSuperview()
        UIView.animate(withDuration: 0.35, animations: {
            self.blurView.alpha = 0.0
            self.imageView.frame = self.imageFrame
            self.imageView.alpha = 0.2
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    private func rekonViewRect() -> (CGRect, CGRect) {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let maxWdith = min(screenWidth - 20.0 * 2, .greatestFiniteMagnitude)

        let testSize = CGSize(width: maxWdith, height: .greatestFiniteMagnitude)
        let layout = XMLTextLayout(attributedString: desc, containerSize: testSize)
        let retSize = layout.textBoundingSize
        let maxHeight = screenHeight - 80.0 * 2.0 - retSize.height

        var imgWidth: CGFloat = maxWdith
        var imgHeight: CGFloat = image.size.height * imgWidth / image.size.width

        if imgHeight > maxHeight {
            imgHeight = maxHeight
            imgWidth = image.size.width * imgHeight / image.size.height
        }

        let imageRect = CGRect(x: (screenWidth - imgWidth) * 0.5, y: (screenHeight - imgHeight - retSize.height) * 0.5 - 30, width: imgWidth, height: imgHeight)

        let descRect = CGRect(x: imageRect.minX, y: imageRect.maxY + 20, width: imageRect.width, height: retSize.height + 80)

        return (imageRect, descRect)
    }
}
