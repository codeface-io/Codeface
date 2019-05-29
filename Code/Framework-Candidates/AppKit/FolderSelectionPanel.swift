import AppKit
import SwiftObserver
import SwiftyToolz

class FolderSelectionPanel: NSOpenPanel
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
        
        message = "Select a Folder"
        canChooseFiles = false
        canChooseDirectories = true
        allowsMultipleSelection = false
    }
    
    func selectFolder(handleFolder: @escaping (URL) -> Void)
    {
        begin()
        {
            guard $0 == .OK, let folder = self.url else
            {
                log(error: "Selecting folder failed.")
                return
            }
            
            handleFolder(folder)
        }
    }
}
