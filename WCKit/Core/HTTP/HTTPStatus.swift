// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

public enum HTTPStatus: Int {
    // 1XX

    case `continue` = 100
    case switchingProtocols = 101
    case processing = 102

    // 2XX

    case ok = 200
    case created = 201
    case accepted = 202
    case nonAuthoritativeInformation = 203
    case noContent = 204
    case resetContent = 205
    case partialContent = 206
    case multiStatus = 207 // WebDAV
    case alreadyReported = 208 // WebDAV
    case imUsed = 226

    // 3XX

    case multipleChoices = 300
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case notModified = 304
    case useProxy = 305
    case switchProxy = 306
    case temporaryRedirect = 307
    case permanentRedirect = 308

    // 4XX

    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case proxyAuthenticationRequired = 407
    case requestTimeout = 408
    case conflict = 409
    case gone = 410
    case lengthRequired = 411
    case preconditionFailed = 412
    case payloadTooLarge = 413
    case uriTooLong = 414
    case unsupportedMediaType = 415
    case rangeNotSatisfiable = 416
    case expectationFailed = 417
    case imATeapot = 418
    case misdirectedRequest = 421
    case unprocessableEntity = 422 // WebDAV
    case locked = 423 // WebDAV
    case failedDependency = 424 // WebDAV
    case upgradeRequired = 426
    case preconditionRequired = 428
    case tooManyRequests = 429
    case requestHeaderFieldsTooLarge = 431
    case unavailableForLegalReasons = 451

    // 5XX

    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case httpVersionNotSupported = 505
    case variantAlsoNegotiates = 506
    case insufficientStorage = 507 // WebDAV
    case loopDetected = 508 // WebDAV
    case notExtended = 510
    case networkAuthenticationRequired = 511

    var isSuccess: Bool { rawValue >= 200 && rawValue < 299 }
    var isClientError: Bool { rawValue >= 400 && rawValue < 499 }
    var isServerError: Bool { rawValue >= 500 && rawValue < 599 }
}

// MARK: - CustomStringConvertible

extension HTTPStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        // 10x

        case .continue:
            return"100 Continue"
        case .switchingProtocols:
            return "101 Switching Protocols"
        case .processing:
            return "102 Processing"

        // 20x

        case .ok:
            return "200 OK"
        case .created:
            return "201 Created"
        case .accepted:
            return "202 Accepted"
        case .nonAuthoritativeInformation:
            return "203 Non-Authoritative Information"
        case .noContent:
            return "204 No Content"
        case .resetContent:
            return "205 Reset Content"
        case .partialContent:
            return "206 Partial Content"
        case .multiStatus:
            return "207 Mult-status (WebDAV)"
        case .imUsed:
            return "226 IM Used"
        case .alreadyReported:
            return "208 Already Reported (WebDAV)"

        // 30x

        case .multipleChoices:
            return "300 Multiple Choices"
        case .movedPermanently:
            return "301 Moved Permantley"
        case .found:
            return "302 Found"
        case .seeOther:
            return "303 See Other"
        case .notModified:
            return "304 Not Modified"
        case .useProxy:
            return "305 Use Proxy"
        case .switchProxy:
            return "306 Switch Proxy"
        case .temporaryRedirect:
            return "307 Temporary Redirect"
        case .permanentRedirect:
            return "308 Permanent Redirect"

        // 40x

        case .badRequest:
            return "400 Bad Request"
        case .unauthorized:
            return "401 Unauthorized"
        case .paymentRequired:
            return "402 Payment Required"
        case .forbidden:
            return "403 Forbidden"
        case .notFound:
            return "404 Not Found"
        case .methodNotAllowed:
            return "405 Method Not Allowed"
        case .notAcceptable:
            return "406 Not Acceptable"
        case .proxyAuthenticationRequired:
            return "407 Proxy Authenticion Required"
        case .requestTimeout:
            return "408 Request Timeout"
        case .conflict:
            return "409 Conflict"
        case .gone:
            return "410 Gone"
        case .lengthRequired:
            return "411 Length Required"
        case .preconditionFailed:
            return "412 Precondition Failed"
        case .payloadTooLarge:
            return "413 Payload Too Large"
        case .uriTooLong:
            return "414 URI Too Long"
        case .unsupportedMediaType:
            return "415 Unsuported Media Type"
        case .rangeNotSatisfiable:
            return "416 Range Not Satisfiable"
        case .expectationFailed:
            return "417 Expectation Failed"
        case .imATeapot:
            return "418 I'm a Teapot"
        case .misdirectedRequest:
            return "421 Misdirected Request"
        case .unprocessableEntity:
            return "422 Unprocessable Entity (WebDAV)"
        case .locked:
            return "423 Locked (WebDAV)"
        case .failedDependency:
            return "424 Failed Dependency (WebDAV)"
        case .upgradeRequired:
            return "426 Upgrade Required"
        case .preconditionRequired:
            return "428 Precondition Required"
        case .tooManyRequests:
            return "429 Too Many Requests"
        case .requestHeaderFieldsTooLarge:
            return "431 Request Header Fields Too Large"
        case .unavailableForLegalReasons:
            return "451 Unavailable For Legal Reasons"

        // 50x

        case .internalServerError:
            return "500 Internal Server Error"
        case .notImplemented:
            return "501 Not Implemented"
        case .badGateway:
            return "502 Bad Gateway"
        case .serviceUnavailable:
            return "503 Service Unavailable"
        case .gatewayTimeout:
            return "504 Gateway Timeout"
        case .httpVersionNotSupported:
            return "505 HTTP Version Not Supported"
        case .variantAlsoNegotiates:
            return "506 Variant Also Negotiates"
        case .insufficientStorage:
            return "507 Insufficient Storage (WebDAV)"
        case .loopDetected:
            return "508 Loop Dected (WebDAV)"
        case .notExtended:
            return "510 Not Extended"
        case .networkAuthenticationRequired:
            return "511 Network Authentication Required"
        }
    }
}
