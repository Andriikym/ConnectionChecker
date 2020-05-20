/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/
import Foundation

typealias QualityMeasureProgress = (Double) -> Void

class ConnectionQualityMeasurer {
    
    // MARK: - Private types

    enum State {
        case ready, inProgress, finished, cancelled
    }
    
    typealias Millisecond = Int
    typealias QualityMeasureCompletion = (ConnectionQuality?) -> Void

    // MARK: - Private properties
    
    private static let numberOfProbes = 5
    private static let probeInterval: Millisecond = 1000
    
    private let workingQueue = DispatchQueue(label: "com.connection_quality_measurer.measuring_queue")
    private let groupe = DispatchGroup()
    private var measureWorkers = [DispatchWorkItem]()
    
    private let timeMeasurer: ConnectionTimeMeasuring
    private let timeAnalyzer: ConnectionTimeAnalyzing
    private let progressHandler: QualityMeasureProgress
    private let completionHandler: QualityMeasureCompletion

    // MARK: - Public properties
    
    var state: State = .ready
    var result: ConnectionQuality?
    
    // MARK: - Initialization & Deallocation

    init(timeMeasurer: ConnectionTimeMeasuring, timeAnalyzer: ConnectionTimeAnalyzing, progressHandler: @escaping QualityMeasureProgress, completionHandler: @escaping QualityMeasureCompletion) {
        self.timeMeasurer = timeMeasurer
        self.timeAnalyzer = timeAnalyzer
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
    }
    
    deinit {
        dPrint("QM deinit")
    }
    
    // MARK: - Public

    func cancel() {
        guard state == .inProgress else { return }
        
        state = .cancelled
        
        workingQueue.async {
            self.measureWorkers.forEach {
                $0.cancel()
                self.groupe.leave()
            }
        }
    }

    /// Starts the measuring. Handler will be called on *Main queue* after finish or cancel.
    func performMeasure() {
        guard state == .ready else {
            if state == .finished {
                completionHandler(result)
            }
            
            return
        }
        
        state = .inProgress
        let measureResult = AtomicStorage<Int, CFTimeInterval?>()
        let now = DispatchTime.now()
        workingQueue.sync {
            for i in 0...Self.numberOfProbes - 1 {
                dPrint("Appending probe - \(i)")
                groupe.enter()
                let work = measureWork(number: i, measureResult: measureResult)
                measureWorkers.append(work)
                let time: DispatchTime = now + .milliseconds(i * Self.probeInterval)
                workingQueue.asyncAfter(deadline: time, execute: work)
            }
        }
        let time = TimeMeasurer() //DEBUG
        groupe.notify(queue: .main) { [weak self] in
            if self?.state == .inProgress {
                let result = self?.timeAnalyzer.analyze(measureResult.values)
                self?.result = result
                self?.state = .finished
            }
            
            dPrint("QM got notify - \(time.measure())")
            self?.completionHandler(self?.result)
        }
    }
    
    // MARK: - Private
    
    private func measureWork(number: Int, measureResult: AtomicStorage<Int, CFTimeInterval?>) -> DispatchWorkItem {
        DispatchWorkItem { [weak self] in
            dPrint("Probe - \(number)")
            
            self?.measureWorkers.removeFirst()
            self?.timeMeasurer.performMeasure { time in
                dPrint("Measure \(number) \(time ?? 0)")
                self?.workingQueue.async {
                    let totalItems = measureResult.setValue(time, forKey: number)
                    let progress = Double(totalItems) / Double(Self.numberOfProbes)
                    DispatchQueue.main.async { self?.progressHandler(progress) }
                    self?.groupe.leave()
                }
            }
        }
    }
}

