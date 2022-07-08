// Copyright © 2016-2022 Velky Brands LLC. All rights reserved.

import Foundation

public enum LoadedData<T> {
    case loading
    case loaded(T)
    case error(Error)
}
