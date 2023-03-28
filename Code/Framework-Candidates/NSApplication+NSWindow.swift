import AppKit
import SwiftyToolz

extension NSApplication
{
    func debugLogWindows()
    {
        for window in windows
        {
            log("🪟 Window:\n\tid = \(window.identifier?.rawValue ?? "nil")\n\tisVisible = \(window.isVisible)\n\tisKeyWindow = \(window.isKeyWindow)")
        }
    }
    
    func closeWindows(where shouldClose: (NSWindow) -> Bool)
    {
        for window in windows
        {
            if shouldClose(window)
            {
                log("🪟 gonna close window with id: \(window.identifier?.rawValue ?? "nil")")
                window.close()
            }
        }
    }
    
    func closeWindowIfOpen(id: String)
    {
        if let window = NSApp.window(withID: id)
        {
            log("🪟 gonna close window with id: \(id)")
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
