import Foundation
import SwiftObserver

extension CodeFileAnalytics
{
    init?(file: URL, folder: URL)
    {
        guard let file = CodeFile(file: file, folder: folder) else
        {
            return nil
        }
        
        self.init(file: file)
    }
}

extension CodeFile
{
    init?(file: URL, folder: URL)
    {
        let filePath = file.absoluteString
        let folderPath = folder.absoluteString
        
        let relativeFilePath = filePath.replacingOccurrences(of: folderPath,
                                                             with: "")
        
        guard filePath != relativeFilePath else
        {
            log(error: "Given file is not in given folder.")
            return nil
        }
        
        guard let code = try? String(contentsOf: file,
                                     encoding: .utf8) else
        {
            return nil
        }
        
        self.init(pathInCodeFolder: relativeFilePath, content: code)
    }
}
