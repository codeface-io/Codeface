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
            
            guard let self = self,
                response == .OK,
                let folder = self.url else { return }
            
            if let files = FileManager.default.files(inDirectory: folder,
                                                     extension: "swift")
            {
                var analytics = files.compactMap
                {
                    CodeFileAnalytics(file: $0, folder: folder)
                }
                
                analytics.sortByLinesOfCode()
                Store.shared.analytics = analytics
            }
        }
    }
}

// MARK: - Framework Candidates

extension FileManager
{
    func files(inDirectory directoryURL: URL,
               extension fileExtension: String) -> [URL]?
    {
        let options: DirectoryEnumerationOptions =
        [
            .skipsHiddenFiles,
            .skipsPackageDescendants
        ]
        
        let urlEnumerator = enumerator(at: directoryURL,
                                       includingPropertiesForKeys: nil,
                                       options: options,
                                       errorHandler: nil)
        
        return urlEnumerator?.compactMap
        {
            guard let fileURL = $0 as? URL,
                fileURL.pathExtension == fileExtension else { return nil }
            
            return fileURL
        }
    }
}
