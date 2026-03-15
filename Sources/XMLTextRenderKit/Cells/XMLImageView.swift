//
//  XMLImageView.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2024/5/27.
//

import UIKit

final class XMLImageView: UIView {
    private let textView = XMLTextView()
    private var imageViews: [UIImageView] = []
    private var image: UIImage?
    private let singleTap: UITapGestureRecognizer

    // MARK: - Interface

    var data: XMLImageData? {
        didSet {
            if let data = data {
                switch data {
                    case .singleImage(let frame, let image):
                        self.image = image
                        setSingleImage(image, frame: frame)
                    case .multiImageDesc(let frames, let images, let desc, let descFrame):
                        self.image = nil
                        setMutiImageDesc(images, frames: frames, desc: desc, descFrame: descFrame)
                }
            }
        }
    }

    var attributedDesc: NSAttributedString?

    init() {
        singleTap = UITapGestureRecognizer()
        super.init(frame: .zero)

        backgroundColor = XMLRenderConfig.shared.xmlImageContainerBackgroundColor
        layer.borderColor = XMLRenderConfig.shared.xmlImageContainerBorderColor?.cgColor
        layer.borderWidth = 0.75

        singleTap.addTarget(self, action: #selector(tapAction(_:)))
        addGestureRecognizer(singleTap)
        isUserInteractionEnabled = true

        textView.isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Utils

    @objc
    private func tapAction(_ tap: UITapGestureRecognizer) {
        if let image = image {
            let imgFrame = self.convert(imageViews.first!.frame, to: nil)
            _ = XMLImageFullScreenView(image: image, imageFrame: imgFrame, desc: attributedDesc!)
        }
    }

    private func setSingleImage(_ image: UIImage, frame: CGRect, desc: XMLTextLayout? = nil, descFrame: CGRect? = nil) {
        if imageViews.count != 1 {
            for view in imageViews {
                view.removeFromSuperview()
            }
            imageViews.removeAll()
            let imageView = UIImageView()
            imageViews.append(imageView)
            addSubview(imageView)
        }

        imageViews.first?.image = image
        imageViews.first?.frame = frame

        if let desc = desc {
            if textView.superview == nil {
                addSubview(textView)
            }

            textView.apply(layout: desc)
            textView.frame = descFrame!
            singleTap.isEnabled = false
        } else {
            textView.removeFromSuperview()
            singleTap.isEnabled = true
        }
    }

    private func setMutiImageDesc(_ images: [UIImage], frames: [CGRect], desc: XMLTextLayout, descFrame: CGRect) {
        if imageViews.count != images.count {
            for view in imageViews {
                view.removeFromSuperview()
            }
            imageViews.removeAll()

            for _ in 0 ..< images.count {
                let imgView = UIImageView()
                imageViews.append(imgView)
                addSubview(imgView)
            }
        }

        for i in 0 ..< images.count {
            let imgView = imageViews[i]
            imgView.image = images[i]
            imgView.frame = frames[i]
        }

        if textView.superview == nil {
            addSubview(textView)
        }

        textView.apply(layout: desc)
        textView.frame = descFrame
        singleTap.isEnabled = false
    }
}
