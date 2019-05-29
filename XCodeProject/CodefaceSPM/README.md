# CodefaceSPM

This package provides all Codeface dependencies that are only available via SPM. The product of CodefaceSPM is a library.

## How it Integrates with Codeface

* An Xcode project was created via `swift package generate-xcodeproj`
* The Xcode project was added as a subproject to `Codeface.xcodeproj`. This way it won't be touched by cocoapods.
* When dependencies in CodefaceSPM change, it will probably suffice to just `swift build`

## Commands

* Build: `swift build`

* Test: `swift test`

* SPM Help: `swift package --help`

