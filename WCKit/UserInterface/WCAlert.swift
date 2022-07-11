// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public class WCAlert {
    public static let notification = Notification.Name("WCAlert.Request")
    
    public enum Severity: String {
        case success
        case info
        case warning
        case error
    }

    public enum Presentation: CustomStringConvertible {
        case modal
        case toast
        case popup(UIViewController, UIView)

        public var description: String {
            switch self {
            case .modal:
                return "modal"
            case .toast:
                return "toast"
            case .popup:
                return "popup"
            }
        }
    }

    public let message: String
    public let title: String
    public let severity: Severity
    public let presentation: Presentation

    private let function: String
    private let file: String
    private let line: Int

    required init(
        message: String,
        title: String,
        severity: Severity,
        presentation: Presentation,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        self.title = title
        self.message = message
        self.severity = severity
        self.presentation = presentation
        self.function = function
        self.file = file
        self.line = line
    }

    private func post() {
        let logMessage =
            """
            {"alert","presentation":\(presentation.description),severity":"\(severity.rawValue)","title":"\(title)","messsage":"\(message)}"
            """

        switch severity {
        case .error, .warning:
            Log.warning(logMessage, function: function, file: file, line: line)
        default:
            Log.info(logMessage, function: function, file: file, line: line)
        }

        NotificationCenter.default.post(name: Self.notification, object: self)
    }

    public static func show(
        _ message: String,
        title: String,
        severity: Severity,
        presentation: WCAlert.Presentation,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        WCAlert(
            message: message,
            title: title,
            severity: severity,
            presentation: presentation,
            function: function,
            file: file,
            line: line
        ).post()
    }

    static func success(
        _ message: String,
        title: String,
        presentation: WCAlert.Presentation = .toast,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        WCAlert(
            message: message,
            title: title,
            severity: .success,
            presentation: presentation,
            function: function,
            file: file,
            line: line
        ).post()
    }

    static func info(
        _ message: String,
        title: String,
        presentation: Presentation = .toast,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        WCAlert(
            message: message,
            title: title,
            severity: .info,
            presentation: presentation,
            function: function,
            file: file,
            line: line
        ).post()
    }

    static func warning(
        _ message: String,
        title: String,
        presentation: Presentation = .toast,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        WCAlert(
            message: message,
            title: title,
            severity: .warning,
            presentation: presentation,
            function: function,
            file: file,
            line: line
        ).post()
    }

    static func error(
        _ message: String,
        title: String,
        presentation: Presentation = .toast,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        WCAlert(
            message: message,
            title: title,
            severity: .error,
            presentation: presentation,
            function: function,
            file: file,
            line: line
        ).post()
    }

    static func error(
        _ error: Error,
        title: String,
        presentation: Presentation = .toast,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        WCAlert(
            message: error.localizedDescription,
            title: title,
            severity: .error,
            presentation: presentation,
            function: function,
            file: file,
            line: line
        ).post()
    }
}
