// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

//
// Based on CleanroomLogger.
// See https://github.com/emaloney/CleanroomLogger
//

public protocol NonSummaryConvertible {}

public protocol SummaryConvertible {
    var summary: String? { get }
}

extension Array: SummaryConvertible where Element: SummaryConvertible {
    public var summary: String? {
        "[" + compactMap(\.summary).joined(separator: ", ") + "]"
    }
}

let dateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'h:mm:ssZ"
    return formatter
}()

// You can add custom log recorders like Papertrail or Sentry

public protocol LogRecorder {
    var identifier: String { get }
    var minimumSeverity: Log.Severity { get }
    func log(_ entry: Log.Entry)
}

public enum Log {
    public enum Severity: Int, Comparable, CustomStringConvertible {
        case fault
        case error
        case warning
        case info
        case debug
        case verbose

        public var description: String {
            switch self {
            case .fault:
                return "FALT"
            case .error:
                return "ERROR"
            case .warning:
                return "WARN"
            case .info:
                return "INFO"
            case .debug:
                return "DEBUG"
            case .verbose:
                return "VERBOSE"
            }
        }

        public static func < (lhs: Severity, rhs: Severity) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    public struct Entry {
        let timestamp: Date
        let message: String
        let severity: Severity
        let function: String
        let file: String
        let line: Int

        init(
            message: String,
            severity: Severity,
            function: String,
            file: String,
            line: Int
        ) {
            timestamp = Date()
            self.message = message
            self.severity = severity
            self.function = function
            self.file = file
            self.line = line
        }
    }

    private static var isStarted = false
    private static var recorders = [LogRecorder]()

    private static let appendQueue = DispatchQueue(
        label: "WCKit.Log.AppendEntry",
        attributes: .concurrent
    )

    private static let formatQueue = DispatchQueue(
        label: "WCKit.Log.FormatEntry",
        attributes: .concurrent
    )

    // MARK: Lifetime

    private static func initializeIfRequired() {
        guard !isStarted else { return }

        isStarted = true
        addRecorder(XcodeLogRecorder(minimumSeverity: .verbose))
    }
    
    // MARK: Configuration
    
    public static func addRecorder(_ recorder: LogRecorder) {
        if recorders.first(where: { $0.identifier == recorder.identifier }) != nil {
            return
        }
        
        recorders.append(recorder)
    }

    // MARK: Fault

    public static func fault(
        _ error: Error,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        appendQueue.async {
            record(
                Entry(
                    message: error.localizedDescription,
                    severity: .error,
                    function: function,
                    file: file,
                    line: line
                )
            )
        }
    }

    public static func fault(
        _ message: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        appendQueue.async {
            record(
                Entry(
                    message: message,
                    severity: .error,
                    function: function,
                    file: file,
                    line: line
                )
            )
        }
    }

    // MARK: Error

    public static func error(
        _ error: Error,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        appendQueue.async {
            record(
                Entry(
                    message: error.localizedDescription,
                    severity: .error,
                    function: function,
                    file: file,
                    line: line
                )
            )
        }
    }

    public static func error(
        _ message: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        appendQueue.async {
            record(
                Entry(
                    message: message,
                    severity: .error,
                    function: function,
                    file: file,
                    line: line
                )
            )
        }
    }

    // MARK: Warning

    public static func warning(
        _ error: Error,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        appendQueue.async {
            record(
                Entry(
                    message: error.localizedDescription,
                    severity: .warning,
                    function: function,
                    file: file,
                    line: line
                )
            )
        }
    }

    public static func warning(
        _ message: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        appendQueue.async {
            record(
                Entry(
                    message: message,
                    severity: .warning,
                    function: function,
                    file: file,
                    line: line
                )
            )
        }
    }

    // MARK: Info

    public static func info(
        _ message: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        appendQueue.async {
            record(
                Entry(
                    message: message,
                    severity: .info,
                    function: function,
                    file: file,
                    line: line
                )
            )
        }
    }

    // MARK: Debug

    public static func debug(
        _ message: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        appendQueue.async {
            record(
                Entry(
                    message: message,
                    severity: .debug,
                    function: function,
                    file: file,
                    line: line
                )
            )
        }
    }

    // MARK: Verbose

    public static func verbose(
        _ message: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        appendQueue.async {
            record(
                Entry(
                    message: message,
                    severity: .verbose,
                    function: function,
                    file: file,
                    line: line
                )
            )
        }
    }

    //

    public static func message(
        _ message: String,
        severity: Log.Severity,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        switch severity {
        case .fault:
            fault(message, function: function, file: file, line: line)
        case .error:
            error(message, function: function, file: file, line: line)
        case .warning:
            warning(message, function: function, file: file, line: line)
        case .info:
            info(message, function: function, file: file, line: line)
        case .debug:
            debug(message, function: function, file: file, line: line)
        case .verbose:
            verbose(message, function: function, file: file, line: line)
        }
    }

    private static func record(_ entry: Entry) {
        formatQueue.async {
            for recorder in Log.recorders where entry.severity <= recorder.minimumSeverity {
                recorder.log(entry)
            }
        }
    }
}

// MARK: - Xcode Logger

private class XcodeLogRecorder: LogRecorder {
    let identifier = "xcode"
    
    let minimumSeverity: Log.Severity

    init(minimumSeverity: Log.Severity) {
        self.minimumSeverity = minimumSeverity
    }

    func log(_ entry: Log.Entry) {
        let fileNameWithExtension = (entry.file as NSString).pathComponents.last ?? "Unknown"
        let fileName = fileNameWithExtension.replacingOccurrences(of: ".swift", with: "")

        let message = "XC "
            + dateTimeFormatter.string(from: entry.timestamp)
            + " \(entry.severity.description) \(entry.message) (\(fileName):\(entry.line))"

        print(message)
    }
}

// MARK: - Example Papertrail Logger

// https://www.papertrail.com
//
// Papertrail is UDP based. In this example we're using
// https://github.com/robbiehanson/CocoaAsyncSocket to
// send the UDP packets.

#if false
private class PapertrailLogRecorder: LogRecorder {
    let minimumSeverity: Log.Severity

    init(minimumSeverity: Log.Severity) {
        self.minimumSeverity = minimumSeverity
    }

    func log(_ entry: Log.Entry) {
        let fileNameWithExtension = (entry.file as NSString).pathComponents.last ?? "Unknown"
        let fileName = fileNameWithExtension.replacingOccurrences(of: ".swift", with: "")

        var parts = [String]()
        parts.append("<22>1") // Log format prefix
        parts.append(entry.timestamp.asISO8601String())
        parts.append("c2smobile") // Sender
        parts.append(Runtime.deviceName) // Component
        parts.append("- - -")
        parts.append(Runtime.buildNumber)
        parts.append(entry.severity.description)

        parts.append(entry.message)
        parts.append("(\(fileName):\(entry.line))")

        var message = parts.joined(separator: " ")

        let maximumCharacters = 900 // UDP length requirements
        if message.count > maximumCharacters {
            message = message.truncated(maximumCharacters, position: .middle)
        }

        guard let data = message.data(using: .utf8, allowLossyConversion: true) else { return }
        PapertrailLogRecorder.getSocket().send(
            data,
            toHost: "logs.papertrailapp.com" /* Replace Host */,
            port: 1234 /* Replace Port Number */,
            withTimeout: -1,
            tag: 1
        )
    }

    class SocketMonitor: NSObject, GCDAsyncUdpSocketDelegate {
        func udpSocket(_ socket: GCDAsyncUdpSocket, didNotConnect error: Error?) {
            let message: String
            if let error = error {
                message = "UPD Socket: " + error.localizedDescription
            } else {
                message = "UPD socket did not connect."
            }
        }

        func udpSocketDidClose(_ socket: GCDAsyncUdpSocket, withError error: Error?) {
            let message: String
            if let error = error {
                message = "UPD socket: " + error.localizedDescription
            } else {
                message = "UPD socket closed."
            }
        }

        func udpSocket(
            _ socket: GCDAsyncUdpSocket,
            didNotSendDataWithTag
            tag: Int,
            dueToError error: Error?
        ) {
            let message: String
            if let error = error {
                message = "UPD socket: " + error.localizedDescription + "."
            } else {
                message = "UPD socket did not send data."
            }
        }
    }

    private static var socket: GCDAsyncUdpSocket?
    private static let socketLock = DispatchSemaphore(value: 1)

    private static func getSocket() -> GCDAsyncUdpSocket {
        socketLock.wait()
        defer { socketLock.signal() }

        guard let socket = PapertrailLogRecorder.socket else {
            let socket = GCDAsyncUdpSocket(
                delegate: SocketMonitor(),
                delegateQueue: DispatchQueue(label: "Log.UDP.Monitor")
            )
            PapertrailLogRecorder.socket = socket
            return socket
        }

        return socket
    }
}
#endif

// MARK: - Example Sentry Logger

// Sentry can report standard logs, but it is most useful
// to report crashes.

// https://sentry.io/welcome/

#if false
private class SentryLogRecorder: LogRecorder {
    var minimumSeverity: Log.Severity

    init(minimumSeverity: Log.Severity) {
        self.minimumSeverity = minimumSeverity
    }

    func log(_ entry: Log.Entry) {
        let fileNameWithExtension = (entry.file as NSString).pathComponents.last ?? "Unknown"
        let fileName = fileNameWithExtension.replacingOccurrences(of: ".swift", with: "")

        var segments = [String]()

        segments.append(dateTimeFormatter.string(from: entry.timestamp))
        segments.append(entry.severity.description)
        segments.append(entry.message)
        segments.append("(\(fileName):\(entry.line))")

        let message = segments.joined(separator: " ")
        SentrySDK.capture(message: message) { scope in
            switch entry.severity {
            case .debug, .verbose: scope.setLevel(.debug)
            case .info: scope.setLevel(.info)
            case .warning: scope.setLevel(.warning)
            case .error, .fault: scope.setLevel(.error)
            case .fault: scope.setLevel(.fatal)
            }
        }
    }
}
#endif
