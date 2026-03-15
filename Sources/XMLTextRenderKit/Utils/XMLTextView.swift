//
//  XMLTextView.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2026/3/6.
//

import UIKit

final class XMLTextView: UITextView, UITextViewDelegate {
    var onPasteAction: ((String) -> Void)?
    var onLinkAction: ((URL) -> Void)?

    init() {
        super.init(frame: .zero, textContainer: nil)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(layout: XMLTextLayout?) {
        guard let layout = layout else {
            attributedText = nil
            return
        }
        layout.apply(to: self)
    }

    private func configure() {
        isEditable = false
        isSelectable = true
        isScrollEnabled = false
        backgroundColor = .clear
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        dataDetectorTypes = []
        delegate = self
        linkTextAttributes = [
            .foregroundColor: XMLRenderConfig.shared.mainColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }

    func textView(
        _ textView: UITextView,
        shouldInteractWith url: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        if XMLTextAction.isPasteURL(url), let text = XMLTextAction.pasteText(from: url) {
            if let handler = onPasteAction {
                handler(text)
            } else {
                handlePaste(text)
            }
            return false
        }

        if let handler = onLinkAction {
            handler(url)
            return false
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return false
    }

    private func handlePaste(_ text: String) {
        UIPasteboard.general.string = text

        guard let currentViewController = UIViewController.currentActiveViewController else {
            return
        }

        let message = "\(text) \(Bundle.localizedString(forKey: "apphelp_pasted"))"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Bundle.localizedString(forKey: "ok"), style: .default)
        alert.addAction(okAction)
        currentViewController.present(alert, animated: true)
    }
}
