// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

public enum DateFormatters {
    static var iso8601DateTime: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    fileprivate static var iso8601DateTimeWithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    static let logEntry: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'h:mm:ssZ"
        return formatter
    }()

    static let filename: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_hhmmss"
        return formatter
    }()
}

public extension Date {
    static let second = 1
    static let minute = second * 60
    static let hour = minute * 60
    static let day = hour * 24
    static let week = day * 7
    static let month = day * 31

    init?(iso8601String string: String) {
        if let date = DateFormatters.iso8601DateTime.date(from: string) {
            self = date
            return
        } else if let date = DateFormatters.iso8601DateTimeWithFractionalSeconds.date(from: string) {
            self = date
            return
        }
        return nil
    }

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        let components = DateComponents(day: 1, second: -1)
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    func trimToDay() -> Date {
        DateFormatters.shortDate.date(from: self.asShortDateString()) ?? self
    }

    var tomorrow: Date {
        var dateComponents = DateComponents()
        dateComponents.setValue(1, for: .day)
        return Calendar.current.date(byAdding: dateComponents, to: Date())!
    }

    func addingDays(_ numDays: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.setValue(numDays, for: .day)
        return Calendar.current.date(byAdding: dateComponents, to: Date())!
    }

    static func numberOfDaysBetween(from date1: Date, to date2: Date) -> Int {
        let calendar = Calendar.current
        let fromDate = calendar.startOfDay(for: date1)
        let toDate = calendar.startOfDay(for: date2)
        let numberOfDays = calendar.dateComponents([.day], from: fromDate, to: toDate)
        return numberOfDays.day!
    }

    func asISO8601String() -> String { DateFormatters.iso8601DateTime.string(from: self) }

    func asShortDateString() -> String { DateFormatters.shortDate.string(from: self) }

    func asShortDateTimeString() -> String { DateFormatters.shortDateTime.string(from: self) }

    func asShortTimeString() -> String { DateFormatters.shortTime.string(from: self) }

    func asFilenameString() -> String { DateFormatters.filename.string(from: self) }

    func asLogEntryString() -> String { DateFormatters.logEntry.string(from: self) }

    func secondsAgo() -> Int { Int(Date().timeIntervalSince(self)) }

    func minutesAgo() -> Int { secondsAgo() / 60 }

    func hoursAgo() -> Int { minutesAgo() / 60 }

    var isToday: Bool { isSameDayAs(Date()) }

    func isSameDayAs(_ date: Date) -> Bool { asShortDateString() == date.asShortDateString() }

    func isYesterday(_ date: Date) -> Bool {
        isSameDayAs(date.addingTimeInterval(-1.0 * 24.0 * 60.0 * 60))
    }

    func isLastWeek(_ date: Date) -> Bool {
        Int(timeIntervalSince(date)) < Date.week
    }

    func isLastMonth(_ date: Date) -> Bool { Int(timeIntervalSince(date)) < Date.month }

    func asTimeAgoString() -> String {
        let now = Date()

        let secondsAgo = Int(now.timeIntervalSince(self))

        if secondsAgo < 0 { return "in the future" }

        if secondsAgo < Date.minute {
            if secondsAgo == 1 {
                return "one second ago"
            } else {
                return "\(secondsAgo) seconds ago"
            }
        }

        if secondsAgo < Date.hour {
            let minutesAgo = (secondsAgo as Int) / Date.minute
            if minutesAgo == 1 {
                return "one minute ago"
            } else {
                return "\(minutesAgo) minutes ago"
            }
        }

        if isSameDayAs(now) {
            let hoursAgo = (secondsAgo as Int) / Date.hour
            if hoursAgo == 1 {
                return "one hour ago"
            } else {
                return "\(hoursAgo) hours ago"
            }
        }

        if isYesterday(now) {
            return "yesterday at \(DateFormatters.shortTime.string(from: self))"
        }

        if isLastWeek(now) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE 'at' h:mm a"
            return formatter.string(from: self)
        }

        if isLastMonth(now) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d 'at' h:mm a"
            return formatter.string(from: self)
        }

        return asShortDateTimeString()
    }
}
