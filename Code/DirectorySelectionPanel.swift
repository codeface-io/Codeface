import AppKit
import SwiftObserver

class DirectorySelectionPanel: NSOpenPanel
{
    override init(contentRect: NSRect,
                  styleMask style: NSWindow.StyleMask,
                  backing backingStoreType: NSWindow.BackingStoreType,
                  defer flag: Bool)
    {
        super.init(contentRect: contentRect,
                   styleMask: style,
                   backing: backingStoreType,
                   defer: flag)
        
        message = "Choose a Code Folder"
        canChooseFiles = false
        canChooseDirectories = true
        allowsMultipleSelection = false
    }
    
    func open()
    {
        begin()
        {
            [weak self] response in
            
            guard let self = self, response == .OK else { return }
            
            log("DIRECTORY: \(self.url)")
        }
    }
}
