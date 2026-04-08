# XMLTextRenderKit

`XMLTextRenderKit` is an iOS text rendering kit based on XML content. It parses XML into structured elements and renders them with `UITableView`, suitable for pages such as About, changelog, legal text, and mixed text-image content.

## Features

- XML-driven content rendering
- Block elements for title, paragraph, list, images, footer, and section
- Inline tags for bold, italic, link, and line break
- Configurable spacing, font size, alignment, and list marker style
- Compatible with legacy inline syntax such as `::b(...)b::` and `::link(...)link::`

## Requirements

- iOS 15.0+
- Swift Package Manager

## Installation

Add the package in Xcode:

1. `File > Add Packages...`
2. Enter the repository URL
3. Select a version and add `XMLTextRenderKit`

Or add it to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/askrsw/XMLTextRenderKit.git", from: "1.0.0")
]
```

## Basic Usage

```swift
import UIKit
import XMLTextRenderKit

let url = Bundle.main.url(forResource: "about_en", withExtension: "xml")!
let config = XMLRenderConfig()
config.mainColor = .systemBlue

let controller = XMLTextRenderViewController(
    xmlUrl: url,
    mainTitle: "About",
    config: config
)
```

## XML Structure

All content must be wrapped in a root node:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<p-contents>
    ...
</p-contents>
```

Typical structure:

```xml
<p-contents>
    <p-section id="about_intro" toppadding="8" bottompadding="8">
        <p-title level="3" underline="false">About</p-title>
        <p-paragraph>
            <b>RetroGo</b> is an emulator frontend.
        </p-paragraph>
        <p-list style="bullet">
            <p-item>Fast startup</p-item>
            <p-item>Supports <a href="https://example.com">external links</a></p-item>
        </p-list>
    </p-section>
</p-contents>
```

## Common Block Attributes

These attributes are parsed by `XMLElementBase` and are available on block elements such as `p-section`, `p-paragraph`, `p-list`, `p-title`, `p-footer`, and `p-images` where applicable.

- `toppadding`: top spacing
- `bottompadding`: bottom spacing
- `leading`: leading inset
- `trailing`: trailing inset
- `fontsize`: text size
- `align`: `left`, `center`, `right`, `justify`

`p-section` will pass its common layout attributes to child `p-paragraph` and `p-list` when those child nodes do not explicitly set their own values.

## Elements

### `p-section`

Container element used to group content.

Attributes:

- `id`: required section identifier
- `section-toppadding`: extra top spacing applied to the first child block
- `section-bottompadding`: extra bottom spacing applied to the last child block
- common block attributes

Example:

```xml
<p-section id="version_1_1_0" toppadding="10" bottompadding="15">
    ...
</p-section>
```

### `p-title`

Title block.

Attributes:

- `level`: title level, currently commonly used as `1`, `2`, `3`, `4`
- `underline`: `true` or `false`
- common block attributes

Example:

```xml
<p-title level="3" underline="false">Version 1.1.0</p-title>
```

### `p-paragraph`

Paragraph text block.

Attributes:

- `marked`: optional boolean flag kept by the element
- `indent`: custom indentation content used to calculate head indent
- common block attributes

Example:

```xml
<p-paragraph toppadding="20" bottompadding="10">
    <b>RetroGo</b> is a high-performance iOS emulator frontend.
</p-paragraph>
```

### `p-list`

List block, suitable for changelog and bullet content.

Attributes:

- `style`: `bullet` or `number`
- `start`: starting index for numbered lists
- `marker-color`: marker color, supports hex and common UIKit color names
- `marker-gap`: spacing between marker and text
- `marker-size`: bullet dot size
- `number-font-size`: numbered marker font size, only used by `style="number"`
- common block attributes

Children:

- `p-item`

Example:

```xml
<p-list style="bullet" marker-color="#4A90E2" marker-gap="10" marker-size="14">
    <p-item>Added a new <b>overlay</b> system.</p-item>
    <p-item>Supports <a href="https://example.com">external links</a>.</p-item>
</p-list>
```

Numbered list example:

```xml
<p-list style="number" start="3" marker-color="secondaryLabel">
    <p-item>Third item</p-item>
    <p-item>Fourth item</p-item>
</p-list>
```

### `p-item`

Child element of `p-list`. It supports inline tags such as `<b>`, `<i>`, `<a>`, and `<br/>`.

Example:

```xml
<p-item>Supports <b>bold text</b> and <a href="https://example.com">links</a>.</p-item>
```

### `p-footer`

Footer text block.

Attributes:

- common block attributes

Example:

```xml
<p-footer toppadding="15" bottompadding="6">
    <a href="https://beian.miit.gov.cn">鲁ICP备2023034487号-9A</a>
</p-footer>
```

### `p-images`

Image group block.

Attributes:

- `spacing`: spacing between images
- `toppadding`
- `bottompadding`
- `leading`
- `trailing`

Children:

- `p-image`

`p-image` attributes:

- `type`: `assets` or `base64`
- `src`: asset name or base64 string
- `width`: optional explicit width
- `height`: optional explicit height
- `title`: optional image title

Example:

```xml
<p-images spacing="20" toppadding="0" bottompadding="10">
    <p-image type="assets" src="image_1" title="Preview 1" />
    <p-image type="assets" src="image_2" title="Preview 2" />
</p-images>
```

## Inline Tags

`p-paragraph`, `p-item`, and `p-footer` support these inline tags:

- `<b>...</b>`: bold text
- `<i>...</i>`: italic text
- `<a href="https://example.com">...</a>`: tappable external link
- `<br/>`: line break

Example:

```xml
<p-paragraph>
    This is <b>bold</b>, <i>italic</i>, and
    <a href="https://example.com">a link</a>.<br/>
    Next line.
</p-paragraph>
```

Links are rendered as tappable text and opened with the system browser by default.

## Legacy Inline Syntax

The current version still keeps compatibility with the earlier inline syntax:

- `::b(text)b::`
- `::i(text)i::`
- `::link(text|url)link::`
- `::link(url)link::`
- `::p(text)p::`
- `::(_n_)::`

New XML content should prefer standard tags such as `<b>`, `<i>`, `<a>`, and `<br/>`.

## Example: About Page

```xml
<p-contents>
    <p-section id="about_intro" toppadding="5" bottompadding="10">
        <p-paragraph>
            <b>RetroGo</b> is a high-performance iOS emulator frontend.
        </p-paragraph>
    </p-section>

    <p-section id="about_policy" toppadding="10" bottompadding="15">
        <p-title level="3" underline="false">Legal</p-title>
        <p-paragraph>
            By using this app, you agree to our
            <a href="https://example.com/policy">Privacy Policy</a> and
            <a href="https://example.com/eula">Terms of Use</a>.
        </p-paragraph>
    </p-section>
</p-contents>
```

## Notes

- The package currently uses `UITableView` for rendering.
- Block attributes and element defaults are both involved in layout. Prefer explicit XML attributes when you need deterministic output.
- For changelog content, prefer `p-list` over multiple standalone `p-paragraph` nodes.

## License

MIT License. See [LICENSE](LICENSE).
