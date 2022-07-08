// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation
import OSLog
import UIKit

public enum Runtime {
    public static var bundleIdentifier: String = Bundle.main.bundleIdentifier!

    public static var buildNumber: String = {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }()

    public static var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    public static var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }

    public static var isSimulator: Bool { TARGET_OS_SIMULATOR == 1 }

    public static var isCatalystApp: Bool {
        if #available(iOS 14.0, *) {
            return ProcessInfo.processInfo.isiOSAppOnMac
        } else {
            return false
        }
    }

    public static var deviceName: String { UIDevice.current.name }

    public static var deviceModelName: String { UIDevice.current.localizedModel }

    public static var osName: String { UIDevice.current.systemName }

    public static var osVersion: String { UIDevice.current.systemVersion }

    public static var documentsDirectory: URL? = {
        guard
            let path = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first else { return nil }

        return path
    }()
}
