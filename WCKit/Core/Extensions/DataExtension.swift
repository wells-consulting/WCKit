// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

extension Data: NonSummaryConvertible {}

extension Data {
    var summary: String? {
        if isEmpty { return "_empty_" }
        if count <= 1024 { return String(data: self, encoding: .utf8) ?? "_not_a_string_" }
        return "_\(count.asByteCount())_".replacingOccurrences(of: " ", with: "_")
    }
}
