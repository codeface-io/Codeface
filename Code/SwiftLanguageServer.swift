import Foundation
import SwiftyToolz

class SwiftLanguageServer
{
    static let instance = SwiftLanguageServer()
    
    private init() {}
    
    func start()
    {
        
        // "xcrun --toolchain swift sourcekit-lsp"
        
        let shellCommand = Process()
        shellCommand.executableURL = URL(fileURLWithPath: "/usr/bin/perl")
        shellCommand.arguments = ["--help"]//  --toolchain swift sourcekit-lsp"]

        do
        {
            try shellCommand.run()
        }
        catch
        {
            log(error: error.localizedDescription)
        }
    }
}
