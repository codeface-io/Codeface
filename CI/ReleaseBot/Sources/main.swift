import Foundation

try changeDirectory(to: "/Users/seb/Desktop/GitHub Repos/Codeface")

let codefaceScheme = XcodeSchemeLocation(projectFolderPath: "XcodeProject",
                                         projectName: "Codeface",
                                         name: "Codeface")

try uploadBuild(of: codefaceScheme, withCredentials: .retrieve())
