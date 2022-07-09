// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

public struct HTTPPayload {
    let data: Data
    let typeName: String?
    let summary: String?

    public static let none = HTTPPayload(data: Data(capacity: 0), typeName: nil, summary: nil)
}
