# XMLTextRenderKit

A lightweight XML-based text rendering kit for iOS using Swift Package Manager (SPM).

## Features
- Parse XML text into renderable elements
- Support for titles, paragraphs, images, sections, and footers
- Configurable layout and styling

## Requirements
- iOS 13.0+
- Swift 5.7+

## Installation
Add the package to your project in Xcode:

1. File > Add Packages...
2. Enter the repository URL
3. Choose the version you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/askrsw/XMLTextRenderKit.git", from: "1.0.0")
]
```

## Usage
```swift
import XMLTextRenderKit

// Initialize and present XMLTextRenderViewController
let vc = XMLTextRenderViewController()
```

## License
MIT License. See `LICENSE` for details.
