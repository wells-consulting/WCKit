// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation

public enum HTTP {
    public enum Method: String {
        case delete = "DELETE"
        case get = "GET"
        case patch = "PATCH"
        case post = "POST"
        case put = "PUT"
    }

    //

    public struct Header: Hashable {
        let value: String
        let field: String
        init(value: String, field: String) {
            self.value = value
            self.field = field
        }

        public static func == (lhs: Header, rhs: Header) -> Bool {
            lhs.field.uppercased() == rhs.field.uppercased()
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(field.uppercased())
        }
    }

    //

    public static let multipartFormBoundary = "AEE829AB-96ED-4566-9801-BBD497C33F7E"

    public enum ContentType {
        case json
        case multipartForm
        case text
        case binary

        public var header: HTTP.Header {
            switch self {
            case .json:
                return HTTP.Header(value: "application/json", field: "Content-Type")

            case .multipartForm:
                return HTTP.Header(
                    value: "multipart/form-data; boundary=\(HTTP.multipartFormBoundary)",
                    field: "Content-Type"
                )
            case .text:
                return HTTP.Header(value: "text/plain", field: "Content-Type")

            case .binary:
                return HTTP.Header(value: "application/octet-stream", field: "Content-Type")
            }
        }
    }

    // MARK: - URL Session

    private static let cookieStorage = HTTPCookieStorage.shared
    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept": "application/json",
            "Accept-Encoding": "gzip, deflate",
            "User-Agent": "WKKit/1.0",
            "X-Requested-With": "WKKit",
            "X-IOSDevice-AppBuildNumber": Runtime.buildNumber,
            "X-IOSDevice-AppBundleIdentifier": Runtime.bundleIdentifier,
            "X-IOSDevice-Name": Runtime.deviceName,
        ]
        config.timeoutIntervalForRequest = 30 * 1000 // 30s
        config.httpCookieStorage = HTTP.cookieStorage
        return URLSession(configuration: config)
    }()

    private static func send(
        to url: URL,
        method: Method,
        payload: HTTPPayload,
        headers: [Header]
    ) async throws -> Data? {
        return try await withCheckedThrowingContinuation { continuation in
            _send(to: url, method: method, payload: payload, headers: headers) { result in
                continuation.resume(with: result)
            }
        }
    }

    private static func _send(
        to url: URL,
        method: Method,
        payload: HTTPPayload,
        headers: [Header],
        completion: @escaping (Result<Data?, Error>) -> Void
    ) {
        let mutableRequest = NSMutableURLRequest(url: url)

        mutableRequest.httpMethod = method.rawValue
        mutableRequest.httpBody = payload.data

        for header in headers {
            mutableRequest.setValue(header.value, forHTTPHeaderField: header.field)
        }

        let request = mutableRequest as URLRequest

        let byteCount = payload.data.count.asByteCount()

        let requestString =
            "-> " +
            "\(request.httpMethod!) " +
            "\(request.url!.description), " +
            "\(byteCount)"

        Log.debug(requestString)

        if
            let stringifiedRequest = HTTP.stringifyRequest(
                request,
                payload: payload
            )
        {
            Log.debug(stringifiedRequest)
        }

        let sentTimestamp = CFAbsoluteTimeGetCurrent()

        session.dataTask(with: request) { data, response, error in

            let stringifiedResponse = HTTP.stringifyResponse(
                response,
                sentTimestamp: sentTimestamp,
                data: data
            )

            Log.debug(stringifiedResponse)

            // Unrecoverable error: response must be an HTTPURLResponse

            guard let httpURLResponse = response as? HTTPURLResponse else {
                let httpError = HTTPError(
                    request: request,
                    response: nil,
                    data: data,
                    error: error
                )
                if let details = httpError.errorDetails {
                    Log.debug("-> Error details: " + details)
                }
                completion(.failure(httpError))
                return
            }

            // Unrecoverable error: status code must be known

            guard let httpStatus = HTTPStatus(rawValue: httpURLResponse.statusCode) else {
                let httpError = HTTPError(
                    request: request,
                    response: httpURLResponse,
                    data: data,
                    error: error
                )
                if let details = httpError.errorDetails {
                    Log.debug("-> Error details: " + details)
                }
                completion(.failure(httpError))
                return
            }

            // Failure is not an option

            guard httpStatus.isSuccess else {
                let httpError = HTTPError(
                    request: request,
                    response: httpURLResponse,
                    data: data,
                    error: error
                )

                completion(.failure(httpError))

                return
            }

            completion(.success(data))

        }.resume()
    }

    // MARK: - HTTP Verbs

    public static func get(
        _ url: URL,
        payload: HTTPPayload,
        headers: [Header]
    ) async throws -> Data? {
        try await send(
            to: url,
            method: .get,
            payload: payload,
            headers: headers
        )
    }

    public static func patch(
        _ url: URL,
        payload: HTTPPayload,
        headers: [Header]
    ) async throws -> Data? {
        try await send(
            to: url,
            method: .patch,
            payload: payload,
            headers: headers
        )
    }

    public static func post(
        _ url: URL,
        payload: HTTPPayload,
        headers: [Header]
    ) async throws -> Data? {
        try await send(
            to: url,
            method: .post,
            payload: payload,
            headers: headers
        )
    }

    public static func put(
        _ url: URL,
        payload: HTTPPayload,
        headers: [Header]
    ) async throws -> Data? {
        try await send(
            to: url,
            method: .put,
            payload: payload,
            headers: headers
        )
    }

    public static func delete(
        _ url: URL,
        payload: HTTPPayload,
        headers: [Header]
    ) async throws -> Data? {
        try await send(
            to: url,
            method: .delete,
            payload: payload,
            headers: headers
        )
    }

    // MARK: - Private Implementation

    private static func stringifyRequest(
        _ request: URLRequest,
        payload: HTTPPayload
    ) -> String? {
        var parts = [String]()

        if let dataSummary = payload.summary {
            if let dataTypeName = payload.typeName {
                parts.append(dataTypeName + ": " + dataSummary)
            } else {
                parts.append(dataSummary)
            }
        }

        if parts.isEmpty { return nil }

        let stringifiedRequest = "-> " + parts.joined(separator: ", ")

        return stringifiedRequest
    }

    private static func stringifyResponse(
        _ response: URLResponse?,
        sentTimestamp: Double,
        data: Data?
    ) -> String {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

        var parts = [String]()
        if let status = HTTPStatus(rawValue: statusCode) {
            parts.append("<- " + status.description)
        } else if statusCode > 0 {
            parts.append("<- \(statusCode)")
        }

        if let length = data?.count {
            parts.append(length.asByteCount())
        }

        let elapsedTime = CFAbsoluteTimeGetCurrent() - sentTimestamp
        if elapsedTime < 1.0 {
            parts.append(String(format: "%d ms", Int(ceil(elapsedTime * 1000.0))))
        } else {
            parts.append(String(format: "%1.2f s", elapsedTime))
        }

        return parts.joined(separator: ", ")
    }
}
