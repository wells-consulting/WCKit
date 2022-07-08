// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation

public struct AppError: LocalizedError {
    public static var unresolved = AppError("Unresolved Error")

    public let summary: String?
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
