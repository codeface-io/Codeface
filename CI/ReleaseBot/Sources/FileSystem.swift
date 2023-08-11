import Foundation

func deleteItem(at relativePath: String) throws {
    let fileManager = FileManager.default
    let currentWorkingPath = fileManager.currentDirectoryPath
    let absolutePath = currentWorkingPath + "/" + relativePath
    try fileManager.removeItem(atPath: absolutePath)
}

func changeDirectory(to directory: String) throws {
    guard FileManager.default.changeCurrentDirectoryPath(directory) else {
        throw "could not change directory to " + directory
    }
}

extension String: Error {}
