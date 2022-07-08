// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

public final class HTTPRequestBuilder {
    public let urlPrefix: String
    private var pathSegments = [String]()
    private var queryParameters = [String]()
    private var requestHeaders = Set<HTTP.Header>()

    public init(urlPrefix: String) {
        self.urlPrefix = urlPrefix
    }

    @discardableResult
    public func setHeader(
        _ value: String,
        forField field: String
    ) -> HTTPRequestBuilder {
        requestHeaders.update(with: HTTP.Header(value: value, field: field))
        return self
    }

    @discardableResult
    public func setContentType(
        _ contentType: HTTP.ContentType
    ) -> HTTPRequestBuilder {
        requestHeaders.update(with: contentType.header)
        return self
    }

    public var headers: [HTTP.Header] {
        var allHeaders = Set<HTTP.Header>()

        for header in requestHeaders { allHeaders.update(with: header) }

        return [HTTP.Header](allHeaders)
    }

    public func appending(_ segment: String) -> HTTPRequestBuilder {
        pathSegments.append(segment.trimmingCharacters(in: .whitespacesAndNewlines))
        return self
    }

    public func appending(
        _ value: Bool,
        forKey key: String
    ) -> HTTPRequestBuilder { appending(value ? "true" : "false", forKey: key) }

    public func appending(
        _ value: Int?,
        forKey key: String
    ) -> HTTPRequestBuilder {
        if let value = value { return appending(String(value), forKey: key) }
        return self
    }

    public func appending(
        _ value: Int64?,
        forKey key: String
    ) -> HTTPRequestBuilder {
        if let value = value { return appending(String(value), forKey: key) }
        return self
    }

    public func appending(
        _ value: String?,
        forKey key: String
    ) -> HTTPRequestBuilder {
        guard let value = value else { return self }

        let keyEscaped = key.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        let valueEscaped = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        queryParameters.append("\(keyEscaped ?? key)=\(valueEscaped ?? value)")

        return self
    }
    
    fileprivate var url: URL {
        var components = [String]()

        components.append(urlPrefix)
        components.append(pathSegments.joined(separator: "/"))

        if !queryParameters.isEmpty {
            components.append("?")
            components.append(queryParameters.joined(separator: "&"))
        }

        let string = components.joined()

        let url = URL(string: string)
        
        if url == nil {
            Log.error("'\(string)' not valid URL")
        }

        return url!
    }
    
    fileprivate func decode<Value: Decodable>(
        _ data: Data?
    ) throws -> Value {
        guard let data = data else {
            let error = AppError("\(Value.self) could not be created: no data")
            throw error
        }

        do {
            let value: Value = try JSON.decode(data)
            if let responseSummary = (value as? SummaryConvertible)?.summary {
                Log.debug("<- \(Value.self): " + responseSummary)
            } else if !(value is NonSummaryConvertible) {
                Log.debug("<- \(Value.self)")
            }
            return value
        } catch {
            throw error
        }
    }
}

// MARK: - Codable

public extension HTTPRequestBuilder {
    
    // MARK: GET
    
    func get() async throws -> Data? {
        try await HTTP.get(url, payload: .none, headers: headers)
    }
    
    func get<Response: Decodable>() async throws -> Response {
        setContentType(.json)

        let response = try await HTTP.get(url, payload: .none, headers: headers)
        
        return try decode(response)
    }
    
    // MARK: POST
    
    func post() async throws -> Data? {
        setContentType(.json)
        
        let response = try await HTTP.post(url, payload: .none, headers: headers)
        
        return response
    }
    
    func post<Response: Decodable>() async throws -> Response {
        setContentType(.json)

        let response = try await HTTP.post(url, payload: .none, headers: headers)

        return try decode(response)
    }
    
    func post(_ payload: Data) async throws -> Data? {
        setContentType(.json)

        let response = try await HTTP.post(
            url,
            payload: HTTPPayload(
                data: payload,
                typeName: "\(payload.self)",
                summary: payload.summary
            ),
            headers: headers
        )
        
        return response
    }
    
    func post(_ data: Data? = nil) async throws -> [String: Any] {
       setContentType(.json)
        
        let payload: HTTPPayload
        if let data = data {
            payload = HTTPPayload(data: data, typeName: nil, summary: data.summary)
        } else {
            payload = .none
        }

        let response = try await HTTP.post(url, payload: payload, headers: headers)
        
        guard
            let response = response,
            let jsonObject = JSONSerialization.decode(response)
        else {
            throw AppError("Returned data not JSON")
        }
        
        return jsonObject
    }
    
    func post<Payload: Encodable>(_ payload: Payload) async throws -> Data? {
        setContentType(.json)

        let summary = (payload as? SummaryConvertible)?.summary

        let encodedPayload = try JSON.encode(payload)
        
        let response = try await HTTP.post(
            url,
            payload: HTTPPayload(
                data: encodedPayload,
                typeName: "\(payload.self)",
                summary: summary ?? encodedPayload.summary
            ),
            headers: self.headers
        )
        
        return response
    }

    func post<Payload: Encodable, Response: Decodable>(
        _ payload: Payload
    ) async throws -> Response {
        setContentType(.json)

        let summary = (payload as? SummaryConvertible)?.summary

        let encodedPayload = try JSON.encode(payload)
        
        let response = try await HTTP.post(
            url,
            payload: HTTPPayload(
                data: encodedPayload,
                typeName: "\(payload.self)",
                summary: summary ?? encodedPayload.summary
            ),
            headers: self.headers
        )
        
        return try decode(response)
    }
    
    func post(
        _ payload: MultipartForm
    ) async throws -> Data? {
        setContentType(.multipartForm)

        let response = try await HTTP.post(
            url,
            payload: HTTPPayload(
                data: payload.generateData(),
                typeName: "\(payload.self)",
                summary: payload.summary
            ),
            headers: headers
        )
        
        return response
    }
    
    func post<Response: Decodable>(
        _ payload: MultipartForm
    ) async throws -> Response {
        setContentType(.multipartForm)

        let response = try await HTTP.post(
            url,
            payload: HTTPPayload(
                data: payload.generateData(),
                typeName: "\(payload.self)",
                summary: payload.summary
            ),
            headers: headers
        )
        
        return try decode(response)
    }
    
    // MARK: PUT

    func put<Payload: Encodable>(
        _ payload: Payload
    ) async throws -> Data? {
        setContentType(.json)

        let summary = (payload as? SummaryConvertible)?.summary

        let encodedPayload = try JSON.encode(payload)
        
        let response = try await HTTP.put(
            url,
            payload: HTTPPayload(
                data: encodedPayload,
                typeName: "\(payload.self)",
                summary: summary ?? encodedPayload.summary
            ),
            headers: self.headers
        )
        
        return response
    }

    func put<Payload: Encodable, Response: Decodable>(
        _ payload: Payload
    ) async throws -> Response {
        setContentType(.json)

        let summary = (payload as? SummaryConvertible)?.summary

        let encodedPayload = try JSON.encode(payload)
        
        let response = try await HTTP.put(
            url,
            payload: HTTPPayload(
                data: encodedPayload,
                typeName: "\(payload.self)",
                summary: summary ?? encodedPayload.summary
            ),
            headers: self.headers
        )
        
        return try decode(response)
    }

    // MARK: DELETE

    func delete() async throws -> Data? {
        setContentType(.json)

        let response = try await HTTP.delete(
            url,
            payload: .none,
            headers: headers
        )
        
        return response
    }
}
