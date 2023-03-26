//
//  LinkedLabel.swift
//  LinkedLabel
//
//  Created by SAITO Tomomi on 2023/03/14.
//

import UIKit

/// LinkedLabel is a label which supports hyperlink.
@objc(PFLinkedLabel) open class LinkedLabel: UILabel {
    // MARK: - Properties

    /// Callback object when link tapped. The default behavior is opening the URL with a default browser.
    @objc open var linkDidTap: ((URL) -> Void) = { url in
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    /// Text storage for linked label
    @objc open var textStorage: NSTextStorage? {
        guard let attributedText = attributedText, attributedText.length > 0 else { return nil }

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0
        let textStorage = NSTextStorage(string: "")
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineBreakMode = lineBreakMode
        textContainer.size = textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).size

        return textStorage
    }

    // MARK: - Public/Open methods

    /// Returns URL if hyperlnk has been tapped.
    /// - parameter touches: Touche objects.
    /// - returns: An URL if hyperlink tapped, otherwise `nil`.
    @objc open func url(at touches: Set<UITouch>) -> URL? {
        guard let attributedText = attributedText,
              attributedText.length > 0,
              let touchLocation = touches.sorted(by: { $0.timestamp < $1.timestamp }).last?.location(in: self),
              let textStorage = textStorage,
              let layoutManager = textStorage.layoutManagers.first,
              let textContainer = layoutManager.textContainers.first else { return nil }

        let characterIndex = layoutManager.characterIndex(
            for: touchLocation,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        guard characterIndex >= 0, characterIndex != NSNotFound else { return nil }

        let glyphRange = layoutManager.glyphRange(
            forCharacterRange: NSRange(location: characterIndex, length: 1),
            actualCharacterRange: nil
        )
        let characterRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        guard characterRect.contains(touchLocation) else { return nil }

        return textStorage.attribute(.link, at: characterIndex, effectiveRange: nil) as? URL
    }

    /// Adds a link to the label with a text.
    /// - parameters:
    ///   - url: An URL
    ///   - text: A text which should be enabled link
    @objc open func addLink(url: URL, rangeOf text: String) {
        guard let string = attributedText?.string as? NSString else { return }
        addLink(url: url, range: string.range(of: text))
    }

    /// Adds a link to the label with a range
    /// - parameters:
    ///   - url: An URL
    ///   - text: A range which should be enabled link
    @objc open func addLink(url: URL, range: NSRange) {
        guard let tempAttributedText = attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
        tempAttributedText.addAttributes([.link: url], range: range)
        attributedText = tempAttributedText
    }

    // MARK: - Overrides
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let url = url(at: touches) {
            linkDidTap(url)
        } else {
            super.touchesEnded(touches, with: event)
        }
    }
}
