import Foundation

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
