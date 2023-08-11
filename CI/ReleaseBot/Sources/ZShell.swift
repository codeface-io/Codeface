import Foundation

@discardableResult
func run(command: String) -> Int32 {
    let zShell = Process()
    zShell.launchPath = "/bin/zsh"
    zShell.arguments = ["-c", command]
    zShell.launch()
    zShell.waitUntilExit()
    return zShell.terminationStatus
}
