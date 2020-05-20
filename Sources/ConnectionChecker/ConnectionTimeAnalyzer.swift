/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

/// Analyzes time of connection to generalize connection quality
public protocol ConnectionTimeAnalyzing {
    /// Analyzes array of connection timings to generalize connection quality
    func analyze(_ times: [CFTimeInterval?]) -> ConnectionQuality
}

/// Analyzes time of connection to generalize connection quality
struct ConnectionTimeAnalyzer: ConnectionTimeAnalyzing {
    
    /// Analyzes array of connection timings to generalize connection quality
    func analyze(_ times: [CFTimeInterval?]) -> ConnectionQuality {
        let count = times.count
        
        guard count > 1, let maxTime = times.compactMap({ $0 }).max() else { return .absent }
        
        let nullTimes = times.filter { $0 == nil }
        if nullTimes.count >= 1 { return .poor }
        
        switch maxTime {
        case 0...0.25:
            return .excellent
        case 0.25...0.5:
            return .good
        case 0.5...1.5:
            return .slow
        default:
            return .poor
        }
    }
}
