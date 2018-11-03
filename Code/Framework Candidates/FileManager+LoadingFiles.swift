import Foundation

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
