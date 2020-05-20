/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

/// The general connection quality
public enum ConnectionQuality: String {
    case absent
    case poor
    case slow
    case good
    case excellent
}

public protocol ConnectionQualityChecking {
    var delegate: ConnectionQualityCheckerDelegate? { get set }
    var inProgress: Bool { get }
    
    func start()
    func cancel()
}

public protocol ConnectionQualityCheckerDelegate: AnyObject {
    func connectionCheckerDidStart(_ instance: ConnectionQualityChecking)
    func connectionCheckerDidFinish(result: ConnectionQuality?, instance: ConnectionQualityChecking)
    func connectionCheckerDidUpdate(progress: Double, instance: ConnectionQualityChecking)
}

public class ConnectionQualityChecker: ConnectionQualityChecking {
    
    // MARK: - Private properties
    
    private var qualityMeasurer: ConnectionQualityMeasurer?
    private let timeAnalyzer: ConnectionTimeAnalyzing
    
    public var inProgress: Bool {
        qualityMeasurer != nil
    }

    // MARK: - Initialization
    
    public init() {
        timeAnalyzer = ConnectionTimeAnalyzer()
    }
    
    public init(timeAnalyzer: ConnectionTimeAnalyzing) {
        self.timeAnalyzer = timeAnalyzer
    }

    // MARK: - Public properties

    public weak var delegate: ConnectionQualityCheckerDelegate?
        
    // MARK: - Public

    public func start() {
        guard !inProgress else { return }

        delegate?.connectionCheckerDidStart(self)
        performMeasure()
    }
    
    public func cancel() {
        qualityMeasurer?.cancel()
    }
    
    // MARK: - Private

    private func performMeasure() {
        let progress: QualityMeasureProgress = { [weak self] progres in
            guard let self = self else { return }

            self.delegate?.connectionCheckerDidUpdate(progress: progres, instance: self)
        }
        
        qualityMeasurer = ConnectionQualityMeasurer(timeMeasurer: ICMPConnectionTimeMeasurer(),
                                                    timeAnalyzer: timeAnalyzer,
                                                    progressHandler: progress) { [weak self] result in
            guard let self = self else { return }

            self.qualityMeasurer = nil
            self.delegate?.connectionCheckerDidFinish(result: result, instance: self)
        }
        
        qualityMeasurer?.performMeasure()
    }
}

