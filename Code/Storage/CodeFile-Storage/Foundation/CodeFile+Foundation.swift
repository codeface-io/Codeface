import Foundation
import SwiftObserver
import SwiftyToolz

extension CodeFile
{
    convenience init?(file: URL, folder: URL)
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
        
        guard let code = try? String(contentsOf: file, encoding: .utf8) else
        {
            return nil
        }
        
        self.init(relativePath: relativeFilePath, content: code)
    }
}
