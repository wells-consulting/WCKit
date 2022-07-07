// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

public struct HTTPError: LocalizedError {
    enum FailureType: CustomStringConvertible {
        case notAuthenticated(Bool) // Need to (re)authenticate
        case notAuthorized(Bool) // Need to have a permission
        case lostConnection // Network connection lost
        case other(HTTPError)

        var description: String {
            switch self {
            case let .notAuthenticated(wasStatusCode):
                return wasStatusCode ? HTTPStatus.forbidden.description : "Found 'NotAuthenticated' in response"
            case let .notAuthorized(wasStatusCode):
                return wasStatusCode ? HTTPStatus.unauthorized.description : "Found 'NotAuthorized' in response"
            case .lostConnection:
                return "lostConnection"
            case let .other(error):
                guard let status = error.status else { return error.localizedDescription }
                return status.description
            }
        }
    }

    //

    let status: HTTPStatus?
    let request: URLRequest
    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?
    let responseText: String?
    let jsonObject: [String: Any]?

    var isSuccess: Bool { status?.isSuccess ?? false }
    var isClientError: Bool { status?.isClientError ?? false }
    var isServerError: Bool { status?.isServerError ?? false }

    private let foundNotAuthenticated: Bool
    private let foundNotAuthorized: Bool
    private let foundAutomatorUnavailable: Bool
    private let requestResponseString: String

    private let errorText: String
    var errorDetails: String? {
        errorText.isEmpty
            ? nil
            : errorText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var errorDescription: String? {
        requestResponseString
            + "\n\n"
            + errorText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var failureType: FailureType {
        switch errorDescription {
        case "The network connection was lost.":
            return .lostConnection
        case "The Internet connection appears to be offline.":
            return .lostConnection
        default:
            // This would come directly from the server and not our app framework
            if status == .unauthorized {
                return .notAuthorized(true)
            }

            // In the app server, we overload 403 using the response text.
            // 'NotAuthenticated' => 401 behavior
            // 'NotAuthorized' => 403 behavior
            if status == .forbidden {
                if foundNotAuthenticated {
                    return .notAuthenticated(false)
                } else if foundNotAuthorized {
                    return .notAuthorized(false)
                }
            }

            return .other(self)
        }
    }

    //

    private static func makeRequestResponseString(
        request: URLRequest,
        response: HTTPURLResponse?,
        status: HTTPStatus?
    ) -> String {
        var string = ""

        string += request.httpMethod ?? "SOME_HTTP_METHOD"
        string += " " + (request.url?.absoluteString ?? "SOME_URL")
        string += ", response: "
        if let httpStatus = status {
            string += httpStatus.description
        } else if let statusCode = response?.statusCode {
            string += String(statusCode)
        } else {
            string += "none"
        }

        return string
    }

    init(request: URLRequest, response: HTTPURLResponse?, data: Data?, error: Error?) {
        status = HTTPStatus(rawValue: response?.statusCode ?? 0)
        self.request = request
        self.response = response
        self.data = data
        self.error = error

        self.requestResponseString = HTTPError.makeRequestResponseString(
            request: request,
            response: response,
            status: status
        )

        var errors = [String]()

        if let error = error {
            errors.append(error.localizedDescription)
        }

        guard let data = data else {
            foundNotAuthenticated = false
            foundNotAuthorized = false
            foundAutomatorUnavailable = false
            responseText = nil
            jsonObject = nil
            errorText = errors.joined(separator: "\n")
            return
        }

        if let fullText = String(data: data, encoding: .utf8) {
            foundNotAuthenticated = fullText == "NotAuthenticated"
            foundNotAuthorized = fullText == "NotAuthorized"
            foundAutomatorUnavailable = fullText == "AutomatorUnavailable"

            let text = String(fullText.prefix(min(fullText.count, 500)))

            if text.starts(with: "<!DOCTYPE html>") {
                let line = "\nResponse looks like HTML:\n" + text
                responseText = line
                errors.append(line)
            } else {
                let line = "\n" + text
                responseText = line
                errors.append(line)
            }
        } else {
            foundNotAuthenticated = false
            foundNotAuthorized = false
            foundAutomatorUnavailable = false
            responseText = nil
        }

        errorText = errors.joined(separator: "\n")

        guard let responseJSON = JSONSerialization.decode(data) else {
            jsonObject = nil
            return
        }

        if let jsonErrorObject = responseJSON["error"] as? [String: Any] {
            jsonObject = jsonErrorObject
        } else {
            jsonObject = responseJSON
        }
    }

    //

    static func status(_ error: Error) -> HTTPStatus? {
        guard let httpError = error as? HTTPError else { return nil }
        return httpError.status
    }

    static func failureType(_ error: Error) -> FailureType? {
        guard let httpError = error as? HTTPError else { return nil }
        return httpError.failureType
    }

    static func object<T: Decodable>(_ error: Error) -> T? {
        guard let httpError = error as? HTTPError else { return nil }
        guard let data = httpError.data else { return nil }

        do {
            let object: T = try JSON.decode(data)
            return object
        } catch {
            return nil
        }
    }
}
