# CodefaceSPM

This package provides all Codeface dependencies that are only available via SPM. The product of CodefaceSPM is a library.

## Notes on how CodefaceSPM Integrates in Codeface

* An Xcode project was created via `swift package generate-xcodeproj`
* The Xcode project was added as a subproject to `Codeface.xcodeproj`. This way it (hopefully) won't be touched by cocoapods.
* When dependencies in CodefaceSPM change, it will hopefully suffice to just `swift build`
* One time, when linker problems occured, I had to manually do this: Targets -> Codeface -> General -> Linked Frameworks and Libraries -> Add -> Workspace -> `CodefaceSPM.framework`

## Commands

* Build: `swift build`

* Test: `swift test`

* SPM Help: `swift package --help`

