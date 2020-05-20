/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

/// Measures connection timing
final class HTTPConnectionTimeMeasurer: ConnectionTimeMeasuring {

    // MARK: - Private properties

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieAcceptPolicy = .never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        configuration.timeoutIntervalForRequest = 3
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        configuration.httpShouldUsePipelining = false
        var result = URLSession(configuration: configuration)
        dPrint("made session")
        return result
    }()
    
    // MARK: - Public

    /// Starts to measure connection time. Consider nil result as timeout or error.
    func performMeasure(completion: @escaping TimeMeasureCompletion) {
        let url = URL(string: "https://google.com")!
        var request = URLRequest(url: url)

        request.httpMethod = "HEAD"
        
        let timeMeasurer = TimeMeasurer()
        let task = session.dataTask(with: request) { (data, response, err) in
            guard err == nil else { completion(nil); return }
            
            let passTime = timeMeasurer.measure()
            completion(passTime)
        }
        
        task.resume()
    }
}

