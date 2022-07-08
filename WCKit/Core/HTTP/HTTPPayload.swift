// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation

public struct HTTPPayload {
    let data: Data
    let typeName: String?
    let summary: String?

    public static let none = HTTPPayload(data: Data(capacity: 0), typeName: nil, summary: nil)
}
