// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import UIKit
import OSLog

public enum Runtime {
    static var bundleIdentifier: String = Bundle.main.bundleIdentifier!

    static var buildNumber: String = {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }()

    static var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    static var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }

    static var isSimulator: Bool { TARGET_OS_SIMULATOR == 1 }

    static var isCatalystApp: Bool {
        if #available(iOS 14.0, *) {
            return ProcessInfo.processInfo.isiOSAppOnMac
        } else {
            return false
        }
    }
    
    static var deviceName: String { UIDevice.current.name }

    static var deviceModelName: String { UIDevice.current.localizedModel }

    static var osName: String { UIDevice.current.systemName }

    static var osVersion: String { UIDevice.current.systemVersion }

    static var documentsDirectory: URL? = {
        guard
            let path = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first else { return nil }

        return path
    }()
}
