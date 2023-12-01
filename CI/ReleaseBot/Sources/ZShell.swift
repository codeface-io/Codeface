import Foundation

@discardableResult
func run(command: String) throws {
    let zShell = Process()
    
    zShell.launchPath = "/bin/zsh"
    zShell.arguments = ["-c", command]
    zShell.launch()
    zShell.waitUntilExit()
    
    if zShell.terminationStatus != 0 {
        throw "Shell command failed"
    }
}
