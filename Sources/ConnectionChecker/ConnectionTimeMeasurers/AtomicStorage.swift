/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

/// Thread safe key/value storage.
final class AtomicStorage<Key, Value> where Key : Hashable {
    private let semaphore = DispatchSemaphore(value: 1)
    private var storage: [Key : Value] = [ : ]
       
    @discardableResult
    func setValue(_ value: Value, forKey key: Key) -> Int {
        semaphore.wait(); defer { semaphore.signal() }
        
        storage[key] = value
        return storage.count
    }
    
    func removeValue(forKey key: Key) -> Value? {
        semaphore.wait(); defer { semaphore.signal() }
        
        return storage.removeValue(forKey: key)
    }
    
    var values: [Value] {
        semaphore.wait(); defer { semaphore.signal() }
        
        return storage.values.map { $0 }
    }
}
