<p align="left">
    <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

# ConnectionChecker

**ConnectionChecker** is a library intended to measure round-trip time of ping messages and to evaluate internet connection quality based on it. Internally it leverages Apple© open-source objective-C library *SimplePing* for sending raw ICMP protocol messages.

## Details

Connection quality is represented by few states which by default means:
- absent - there is no ping messages was received;
- poor - some ping messages were lost or taken more than 1500 milliseconds;
- slow - the worse response time was in 500 - 1500 milliseconds;
- good - the worse response time was in 250 - 500 milliseconds;
- excellent - response time is lower than 250 milliseconds;

Custom time analyzation logic can be provided by implementing of **ConnectionTimeAnalyzing** protocol function    
```swift
 func analyze(_ times: [CFTimeInterval?]) -> ConnectionQuality
```
in custom object and providing it at initialization.

## Usage

Evaluating internet connection quality is performing by **ConnectionQualityChecker** instance. As said earlier, it can be initialized with a custom implementation of analyzation.


After calling ***Start***, sending of five ping messages to *Google Public DNS* server at *8.8.8.8* will be started. Delegate function
```swift
func connectionCheckerDidStart(_ instance: ConnectionQualityChecking)
```
 will be called.


During send process delegate function
```swift
func connectionCheckerDidUpdate(progress: Double, instance: ConnectionQualityChecking)
```

will be called periodically to reflect progress.

After finish, the result of evaluating will be presented by the call of delegate function
```swift
    func connectionCheckerDidFinish(result: ConnectionQuality?, instance: ConnectionQualityChecking)
```

Measuring process can be canceled at any time by calling ***Cancel***. In that case finish result will be *nil*.

## Installation

As *ConnectionChecker* is a library created as Swift Package, it can be installed by simply adding it via Xcode’s *Swift Packages* option within the File menu or project's *Swift Packages* tab. (Both starting with Xcode 11).

Or it can be added directly as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/Andriikym/ConnectionChecker.git", from: "0.1.0")
    ],
    ...
)
```

Hope it will be useful 😀
