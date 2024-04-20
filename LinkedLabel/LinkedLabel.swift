/*
 Copyright 2023 SAITO Tomomi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
        add(textLinks: [.init(url: url, text: text)])
        guard let string = attributedText?.string as? NSString else { return }
        addLink(url: url, range: string.range(of: text))
    }
    
    /// Adds multiple links to the label with texts
    ///
    /// This method is can be used only in Swift.
    ///
    /// - parameter textLinks: An array of `TextLink`.
    open func add(textLinks: [TextLink]) {
        guard let text = attributedText?.string as? NSString else { return }
        let rangeLinks: [RangeLink] = textLinks.compactMap { link in
            let range = text.range(of: link.text)
            guard range.location != NSNotFound else { return nil }
            return .init(url: link.url, range: range)
        }
        add(rangeLinks: rangeLinks)
    }

    /// Adds a link to the label with a range
    /// - parameters:
    ///   - url: An URL
    ///   - text: A range which should be enabled link
    @objc open func addLink(url: URL, range: NSRange) {
        add(rangeLinks: [.init(url: url, range: range)])
    }
    
    /// Adds multiple links to the label with ranges
    ///
    /// This method is can be used only in Swift.
    ///
    /// - parameter rangeLinks: An array of `RangeLink`.
    open func add(rangeLinks: [RangeLink]) {
        guard let tempAttributedText = attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
        rangeLinks.forEach { link in
            tempAttributedText.addAttributes([.link: link.url], range: link.range)
        }
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
