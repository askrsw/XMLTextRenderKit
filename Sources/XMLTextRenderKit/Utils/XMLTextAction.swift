//
//  XMLTextAction.swift
//  XMLTextRenderKit
//
//  Created by haharsw on 2026/3/6.
//

import Foundation

enum XMLTextAction {
    static let pasteScheme = "xmltextkit-paste"

    static func makePasteURL(text: String) -> URL? {
        var components = URLComponents()
        components.scheme = pasteScheme
        components.host = "paste"
        components.queryItems = [URLQueryItem(name: "text", value: text)]
        return components.url
    }

    static func isPasteURL(_ url: URL) -> Bool {
        url.scheme == pasteScheme
    }

    static func pasteText(from url: URL) -> String? {
        guard isPasteURL(url) else { return nil }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == "text" })?.value
    }
}
