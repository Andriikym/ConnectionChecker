/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation
import SimplePing

/// Measures connection timing
final class ICMPConnectionTimeMeasurer: NSObject, ConnectionTimeMeasuring {
    
    // MARK: - Private types

    typealias PingMeasure = (timeMeasurer: TimeMeasurer, handler: TimeMeasureCompletion, cancelAction: DispatchWorkItem)
    typealias Action = () -> Void
    typealias PacketNumber = UInt16

    // MARK: - Private properties
    
    private static let targetHost = "8.8.8.8"

    private let timeout: Double
    
    private var measurers =  AtomicStorage<PacketNumber, PingMeasure>()
    private var coldMeasureActions = [Action]()

    private let pinger: SimplePing
    
    private let pingQueue = DispatchQueue(label: "com.icmp-connection-checker.ping-queue")
    private let timeoutQueue = DispatchQueue(label: "com.icmp-connection-checker.timeout-queue", attributes: .concurrent)
    
    // MARK: - Initialization & Deallocation

    init(timeout: TimeInterval = 3.0) {
        self.timeout = timeout
        let pinger = SimplePing(hostName: Self.targetHost)
        self.pinger = pinger
        
        super.init()
        pinger.delegate = self
        pinger.start()
        dPrint("ICMP measurer finish init")
    }
    
    deinit {
        pinger.stop()
        dPrint("Time measurert dealll")
    }
    
    // MARK: - Public
    
    /// Starts to measure connection time. Consider nil result as timeout or error.
    func performMeasure(completion: @escaping TimeMeasureCompletion) {
        guard pinger.hostAddress != nil else { // Check pinger warmed up
            dPrint("Putting cold measurer")
            let coldMeasurer = measureWith(pinger: pinger, completion: completion)
            coldMeasureActions.append(coldMeasurer)
            return
        }
    
        pingQueue.async {
            self.measureWith(pinger: self.pinger, completion: completion)()
        }
    }
    
    // MARK: - Private

    private func measureWith(pinger: SimplePing, completion: @escaping TimeMeasureCompletion) -> Action {
        
    { [weak self] in
        let sequenceNumber = pinger.nextSequenceNumber
        
        let cancelWork = DispatchWorkItem { [weak self] in
            dPrint("Timeout fired for \(sequenceNumber)")
            self?.handlePacketWithNumber(sequenceNumber, shouldCancel: true)
        }
        
        let measure = (timeMeasurer: TimeMeasurer(), handler: completion, cancelAction: cancelWork)
        self?.measurers.setValue(measure, forKey: sequenceNumber)
        
        self?.timeoutQueue.asyncAfter(deadline: .now() + (self?.timeout ?? 0), execute: measure.cancelAction)
        pinger.send(with: nil)
        }
    }
    
    private func handlePacketWithNumber(_ number: PacketNumber, shouldCancel: Bool) {
        dPrint("Dequeueing measurer \(number)")
        let action = measurers.removeValue(forKey: number)
        action == nil ? dPrint("No action for \(number)") : dPrint("Execute action for \(number)")
        action?.cancelAction.cancel()
        action?.handler(shouldCancel ? nil : action?.timeMeasurer.measure())
    }
}

extension ICMPConnectionTimeMeasurer: SimplePingDelegate {
    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: PacketNumber) {
        dPrint("didSendPacket - \(sequenceNumber)")
    }
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: PacketNumber) {
        dPrint("didReceivePingResponsePacket - \(sequenceNumber)")

        handlePacketWithNumber(sequenceNumber, shouldCancel: false)
    }
    
    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: PacketNumber, error: Error) {
        dPrint("didFailToSendPacket - \(sequenceNumber)")

        handlePacketWithNumber(sequenceNumber, shouldCancel: true)
    }
        
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        dPrint("didStartWithAddress")
        
        pingQueue.async {
            dPrint("processing cold measurers \(self.coldMeasureActions.count)")
            self.coldMeasureActions.forEach { $0() }
            self.coldMeasureActions = []
        }
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        dPrint("didFailWithError")
    }
    
    func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) { }
}
