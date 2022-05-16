import Foundation

extension FileManager
{
    func items(inDirectory directory: URL, recursive: Bool = true) -> [URL]?
    {
        var options: DirectoryEnumerationOptions =
        [
            .skipsHiddenFiles,
            .skipsPackageDescendants
        ]
        
        if !recursive
        {
            options.insert(.skipsSubdirectoryDescendants)
        }
        
        return enumerator(at: directory,
                          includingPropertiesForKeys: [.isDirectoryKey],
                          options: options,
                          errorHandler: nil)?.compactMap { $0 as? URL }
    }
}
