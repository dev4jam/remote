<p align="center">
    <img src="https://img.shields.io/cocoapods/v/Remote.svg?style=flat" />
    <img src="https://img.shields.io/badge/platform-iOS%2010%2B-blue.svg?style=flat" alt="Platform: iOS 10+" />
    <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" alt="Language: Swift 4.0" /></a>
    <img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="License: MIT" />
    <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
    <a href="https://twitter.com/dev4jam"><img src="http://img.shields.io/badge/contact-@dev4jam-blue.svg?style=flat"/></a>
</p>

# Remote

Remote is a highly decoupled/isolated and testable networking layer written in Swift.

## Architecture Design

Current version is based upon the network architecture design described in:

- Atlas networking layer: [link](https://medium.com/iquii/atlas-an-unified-approach-to-mobile-development-cycle-networking-layer-a5ccb064181a)
- The complete guide to Network Unit Testing in Swift: [link](https://medium.com/flawless-app-stories/the-complete-guide-to-network-unit-testing-in-swift-db8b3ee2c327)
- Network Layers in Swift: [link](http://danielemargutti.com/2017/09/10/how-to-write-networking-layer-in-swift-2nd-version/)
- Ultimate Guide to JSON Parsing with Swift 4: [link](https://benscheirman.com/2017/06/swift-json/)
- Under the hood of Futures & Promises in Swift [link](https://www.swiftbysundell.com/posts/under-the-hood-of-futures-and-promises-in-swift)

## Used Libraries

In order to give a complete out-of-box approach I’ve used the following libraries:

* **Reactive Programming in Swift**: As a callback hell solution [RxSwift](https://github.com/ReactiveX/RxSwift)
* **Realm**: Caching [realm.io](https://realm.io)

## Installation
You can install Swiftline using CocoaPods, carthage and Swift package manager

### CocoaPods

```
use_frameworks!
pod 'Remote'
```

### Carthage
```
github 'dev4jam/Remote'
```

### Swift Package Manager
Add swiftline as dependency in your `Package.swift`

```
import PackageDescription

let package = Package(name: "YourPackage",
dependencies: [
    .Package(url: "https://github.com/dev4jam/Remote.git", majorVersion: 0),
  ]
)
```

<a name="requirements" />
