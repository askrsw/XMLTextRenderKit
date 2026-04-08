//
//  XMLRenderConfig.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2026/3/6.
//

import UIKit

public class XMLRenderConfig {
    internal static var shared = XMLRenderConfig()

    public var xmlImageContainerBackgroundColor: UIColor?
    public var xmlImageContainerBorderColor: UIColor?
    public var mainColor: UIColor

    public var maxRenderViewWidth: CGFloat
    public var currentLanguageKey: String

    public init() {
        self.xmlImageContainerBackgroundColor = {
            if UIColor.isDarkMode {
                return .init(hex: 0x1F1F1F)
            } else {
                return .init(hex: 0xEBEBEB)
            }
        }()
        self.xmlImageContainerBorderColor = {
            if UIColor.isDarkMode {
                return .init(hex: 0x444444)
            } else {
                return .init(hex: 0xBABABA)
            }
        }()
        self.mainColor = UIColor.label
        self.maxRenderViewWidth = UIScreen.main.bounds.width
        self.currentLanguageKey = {
            let laguages = NSLocale.preferredLanguages
            if let first = laguages.first, first.hasPrefix("zh") {
                return "zh"
            } else {
                return "en"
            }
        }()
    }

    internal var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    internal var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    internal var isPortrait: Bool {
        UIScreen.main.bounds.width < UIScreen.main.bounds.height
    }
}
