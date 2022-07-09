// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

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

public protocol Recorder {
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
    private static var isRemoteLoggingEnabled = false
    private static var recorders = [Recorder]()

    private static let appendQueue = DispatchQueue(
        label: "Log.AppendEntry",
        attributes: .concurrent
    )

    private static let formatQueue = DispatchQueue(
        label: "Log.FormatEntry",
        attributes: .concurrent
    )

    // MARK: Lifetime

    public static func initialize(isRemoteLoggingEnabled: Bool) {
        guard !isStarted else {
            return
        }

        Log.isStarted = true

        Log.isRemoteLoggingEnabled = isRemoteLoggingEnabled

        Log.recorders.append(XcodeLogRecorder(minimumSeverity: .verbose))
    }

    // MARK: Fault

    public static func fault(
        _ error: Error,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        Log.appendQueue.async {
            Log.record(
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
        Log.appendQueue.async {
            Log.record(
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
        Log.appendQueue.async {
            Log.record(
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
        Log.appendQueue.async {
            Log.record(
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
        Log.appendQueue.async {
            Log.record(
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
        Log.appendQueue.async {
            Log.record(
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
        Log.appendQueue.async {
            Log.record(
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
        Log.appendQueue.async {
            Log.record(
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
        Log.appendQueue.async {
            Log.record(
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
            Log.fault(message, function: function, file: file, line: line)
        case .error:
            Log.error(message, function: function, file: file, line: line)
        case .warning:
            Log.warning(message, function: function, file: file, line: line)
        case .info:
            Log.info(message, function: function, file: file, line: line)
        case .debug:
            Log.debug(message, function: function, file: file, line: line)
        case .verbose:
            Log.verbose(message, function: function, file: file, line: line)
        }
    }

    private static func record(_ entry: Entry) {
        Log.formatQueue.async {
            for recorder in Log.recorders where entry.severity <= recorder.minimumSeverity {
                recorder.log(entry)
            }
        }
    }
}

// MARK: - Xcode

private class XcodeLogRecorder: Recorder {
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
