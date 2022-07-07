// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

public struct WCError: LocalizedError {
    static var unresolved = WCError("Unresolved Error")

    let summary: String?
    public let errorDescription: String?

    init(_ error: Error) {
        summary = "Unresolved Error"
        if let nsError = error as NSError? {
            errorDescription = "Unresolved error \(nsError), \(nsError.userInfo)"
        } else {
            errorDescription = error.localizedDescription
        }
    }

    init(_ summary: String, details: String? = nil) {
        self.summary = summary
        errorDescription = details ?? summary
    }
}
