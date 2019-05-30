# CodefaceSPM

This library provides Codeface dependencies that are only available via SPM.

## How CodefaceSPM Integrates in Codeface

To make the dependencies available to the main project, the following steps were taken:

1. An Xcode project was created via `swift package generate-xcodeproj`
2. The generated `CodefaceSPM.xcodeproj` was added as a subproject to `Codeface.xcodeproj`. This way it (hopefully) won't be touched by cocoapods.
3. One time, when linker problems occured, I had to manually do this: Targets -> Codeface -> General -> Linked Frameworks and Libraries -> Add -> Workspace -> `CodefaceSPM.framework`
4. To be able to copy the created app bundle (executable) somewhere for usage and testing, the frameworks of CodefaceSPM had to be imbedded in the main target: Targets -> Codeface -> Build Phases -> Embed Frameworks -> Add -> select all frameworks from `CodefaceSPM.xcodeproj/Products` except for `CodefaceSPMTest.xctest`

When dependencies in CodefaceSPM change, it will hopefully suffice to `swift build` and then adjust the embedded frameworks according to step (4).

## Commands

* Build: `swift build`

* Test: `swift test`

* SPM Help: `swift package --help`

