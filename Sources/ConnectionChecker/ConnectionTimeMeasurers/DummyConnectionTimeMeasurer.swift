/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

class DummyConnectionTimeMeasurer: ConnectionTimeMeasuring {
    func performMeasure(completion: @escaping TimeMeasureCompletion) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            let range = 0.1...0.5
            let result = Double.random(in: range)
            completion(result)
        }
    }
}
