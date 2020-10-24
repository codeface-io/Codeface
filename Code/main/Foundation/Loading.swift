import Foundation

class Loading
{
    static func loadFiles(fromNewFolder newFolder: URL)
    {
        if let files = CodeFileLoading.loadFiles(fromNewFolder: newFolder)
        {
            load(files: files)
        }
    }
    
    static func loadFilesFromLastFolder()
    {
        if let files = CodeFileLoading.loadFilesFromLastFolder()
        {
            load(files: files)
        }
    }
    
    static func load(files: [CodeFile])
    {
        CodeFileStore.shared.elements = files
        
        let analyzer = CodeFileAnalyzer()
        
        let analytics = analyzer.analyze(CodeFileStore.shared.elements)
        
        CodeFileAnalyticsStore.shared.set(elements: analytics)
    }
}
