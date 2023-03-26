//
//  RangeLink.swift
//  LinkedLabel
//
//  Created by SAITO Tomomi on 2023/03/26.
//  Copyright © 2023 Project Flora. All rights reserved.
//

import Foundation

/// Link object with range for `LinkedLabel`
public struct RangeLink {
    /// URL for the link object
    public let url: URL

    /// Text range for the link object
    public let range: NSRange
}
 
