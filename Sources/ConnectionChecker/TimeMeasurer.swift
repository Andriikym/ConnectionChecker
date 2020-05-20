/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

/// Measures time.
protocol TimeMeasuring {
    /// Shows time passed between instance creation and first call for this function
    func measure() -> CFAbsoluteTime
}

/// Measures time.
///
/// Usage: Create the instance at required starting time. When time need to be measured call for
/// **measure()**
final class TimeMeasurer: TimeMeasuring {
    typealias TimeProvider = () -> (CFAbsoluteTime)
    
    // MARK: - Private properties

    var timeProvider: TimeProvider
    private let startTime: CFAbsoluteTime
    private var finishTime: CFAbsoluteTime = 0
    private var duration: CFAbsoluteTime {
        finishTime - startTime
    }
    
    // MARK: - Public

    init(timeProvider: @escaping @autoclosure TimeProvider = CFAbsoluteTimeGetCurrent()) {
        self.timeProvider = timeProvider
        self.startTime = timeProvider()
    }
    
    /// Shows time passed between instance creation and first call for this function
    func measure() -> CFAbsoluteTime {
        guard finishTime == 0 else { return duration }
        
        finishTime = timeProvider()
        return duration
    }
}
