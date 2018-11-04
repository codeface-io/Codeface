import Foundation

extension FileManager
{
    func files(inDirectory directoryURL: URL,
               extension fileExtension: String,
               skipFolders: [String] = []) -> [URL]?
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
            
            let urlString = fileURL.absoluteString
            
            for unwantedFolder in skipFolders
            {
                if urlString.contains(unwantedFolder) { return nil }
            }
            
            return fileURL
        }
    }
}
