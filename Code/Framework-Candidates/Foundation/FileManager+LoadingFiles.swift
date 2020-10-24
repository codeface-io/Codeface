import Foundation

extension FileManager
{
    func files(inDirectory directory: URL,
               flat: Bool = false,
               skipFolders: [String] = []) -> [URL]?
    {
        var options: DirectoryEnumerationOptions =
        [
            .skipsHiddenFiles,
            .skipsPackageDescendants
        ]
        
        if flat
        {
            options.insert(.skipsSubdirectoryDescendants)
        }
        
        return enumerator(at: directory,
                          includingPropertiesForKeys: [.isDirectoryKey],
                          options: options,
                          errorHandler: nil)?
        .compactMap
        {
            $0 as? URL
        }
        .filter
        {
            let pathComponents = Set($0.pathComponents)
            
            for folderToSkip in skipFolders
            {
                if pathComponents.contains(folderToSkip) { return false }
            }
            
            return true
        }
    }
}
