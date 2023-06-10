import AppKit
import SwiftyToolz

extension NSApplication
{
    func debugLogWindows()
    {
        guard !windows.isEmpty else
        {
            return log("🪟 There are no windows")
        }
        
        let output: String = windows.map
        {
            "🪟 Window:\n\tid = \($0.identifier?.rawValue ?? "nil")\n\tisVisible = \($0.isVisible)\n\tisKeyWindow = \($0.isKeyWindow)"
        }
        .joined(separator: "\n")
        
        log(output)
    }
    
    func closeWindows(where shouldClose: (NSWindow) -> Bool)
    {
        for window in windows
        {
            if shouldClose(window)
            {
                log(verbose: "🪟 gonna close window with id: \(window.identifier?.rawValue ?? "nil")")
                window.close()
            }
        }
    }
    
    func closeWindowIfOpen(id: String)
    {
        if let window = NSApp.window(withID: id)
        {
            log(verbose: "🪟 gonna close window with id: \(id)")
            window.close()
        }
    }
    
    func windowExists(withID id: String) -> Bool
    {
        window(withID: id) != nil
    }
    
    func window(withID id: String) -> NSWindow?
    {
        windows.first { $0.identifier?.rawValue == id }
    }
}
