// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation

public enum ControlState {
    case disabled(String?)
    case hidden
    case normal

    public var isDisabled: Bool {
        if case .disabled = self { return true }
        return false
    }

    public var isHidden: Bool {
        if case .hidden = self { return true }
        return false
    }
}
