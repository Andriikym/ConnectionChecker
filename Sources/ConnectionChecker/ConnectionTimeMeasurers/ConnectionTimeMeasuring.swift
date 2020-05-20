/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

typealias TimeMeasureCompletion = (CFTimeInterval?) -> ()

/// Measures connection timing
protocol ConnectionTimeMeasuring {
    /// Starts to measure connection time. Consider nil result as timeout or error.
    func performMeasure(completion: @escaping TimeMeasureCompletion)
}
