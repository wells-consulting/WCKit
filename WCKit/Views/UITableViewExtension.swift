// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

public enum LoadedData<T> {
    case loading
    case loaded(T)
    case error(Error)
}
