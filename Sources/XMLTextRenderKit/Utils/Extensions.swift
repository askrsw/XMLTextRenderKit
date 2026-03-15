//
//  Extensions.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2026/3/6.
//

import UIKit

extension UIColor {
    internal convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8 ) & 0xFF) / 255
        let b = CGFloat( hex        & 0xFF) / 255

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    internal static var isDarkMode: Bool {
        UIScreen.main.traitCollection.userInterfaceStyle == .dark
    }
}

extension UIView {

    internal var origin: CGPoint {
        get { self.frame.origin }
        set { self.frame.origin = newValue }
    }

    internal var size: CGSize {
        get { self.frame.size }
        set { self.frame.size = newValue }
    }

    internal var x: CGFloat {
        get { origin.x }
        set { self.frame.origin.x = newValue }
    }

    internal var minX: CGFloat {
        origin.x
    }

    internal var maxX: CGFloat {
        origin.x + width
    }

    internal var y: CGFloat {
        get { origin.y }
        set { self.frame.origin.y = newValue }
    }

    internal var minY: CGFloat {
        origin.y
    }

    internal var maxY: CGFloat {
        origin.y + height
    }

    internal var centerX: CGFloat {
        get { center.x }
        set { center.x = newValue }
    }

    internal var centerY: CGFloat {
        get { center.y }
        set { center.y = newValue }
    }

    internal var width: CGFloat {
        get { size.width }
        set { self.frame.size.width = newValue }
    }

    internal var height: CGFloat {
        get { size.height }
        set { self.frame.size.height = newValue }
    }

    internal var tx: CGFloat {
        get { self.transform.tx }
        set { self.transform.tx = newValue }
    }

    internal var ty: CGFloat {
        get { self.transform.ty }
        set { self.transform.ty = newValue }
    }

    internal var left: CGFloat {
        get { self.x }
    }

    internal var right: CGFloat {
        get { self.frame.maxX }
    }
}

extension UIWindow {
    internal class var currentKeyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            if let activeScene = windowScenes.first(where: { $0.activationState == .foregroundActive }) {
                return activeScene.windows.first(where: { $0.isKeyWindow }) ?? activeScene.windows.first
            }
            let allWindows = windowScenes.flatMap { $0.windows }
            return allWindows.first(where: { $0.isKeyWindow }) ?? allWindows.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

extension UIViewController {
    internal class var currentActiveViewController: UIViewController? {
        if let rootViewController = UIWindow.currentKeyWindow?.rootViewController {
            return getCurrentViewController(rootViewController: rootViewController)
        } else {
            return nil
        }
    }

    private static func getCurrentViewController(rootViewController: UIViewController) -> UIViewController? {
        if let tabbarController = rootViewController as? UITabBarController, let secetedController = tabbarController.selectedViewController {
            return getCurrentViewController(rootViewController: secetedController)
        }

        if let naviController = rootViewController as? UINavigationController {
            if let visibleController = naviController.visibleViewController {
                return getCurrentViewController(rootViewController: visibleController)
            }
        }

        if let controller = rootViewController.presentedViewController {
            return getCurrentViewController(rootViewController: controller)
        } else {
            return rootViewController
        }
    }
}

extension Bundle {
    static func localizedString(forKey key: String) -> String {
        Bundle.module.localizedString(
            forKey: key,
            value: nil,
            table: XMLRenderConfig.shared.currentLanguageKey
        )
    }
}

extension NSAttributedString {
    var rangeOfAll: NSRange {
        NSRange(location: 0, length: length)
    }
}
