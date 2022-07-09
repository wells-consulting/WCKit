// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit

public class WCAlert {
    static let notification = Notification.Name("WCAlert.Present")
    
    enum Severity: String {
        case success
        case info
        case warning
        case error
    }

    enum Presentation: CustomStringConvertible {
        case modal
        case toast
        case popup(UIViewController, UIView)

        var description: String {
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

    let message: String
    let title: String
    let severity: Severity
    let presentation: Presentation

    private let function: String
    private let file: String
    private let line: Int

    required init(
        message: String,
        title: String,
        style: Severity,
        presentation: Presentation,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        self.title = title
        self.message = message
        self.severity = style
        self.presentation = presentation
        self.function = function
        self.file = file
        self.line = line
    }

    private func post() {
        let logMessage =
            """
            {"alert","presentation":\(presentation.description),style":"\(severity.rawValue)","title":"\(title)","messsage":"\(message)}"
            """

        switch severity {
        case .error, .warning:
            Log.warning(logMessage, function: function, file: file, line: line)
        default:
            Log.info(logMessage, function: function, file: file, line: line)
        }

        NotificationCenter.default.post(name: Self.notification, object: self)
    }

    private static func show(
        _ message: String,
        title: String,
        style: Severity,
        presentation: WCAlert.Presentation,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        WCAlert(
            message: message,
            title: title,
            style: style,
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
            style: .success,
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
            style: .info,
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
            style: .warning,
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
            style: .error,
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
            style: .error,
            presentation: presentation,
            function: function,
            file: file,
            line: line
        ).post()
    }
}
