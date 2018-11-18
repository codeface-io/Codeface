import Foundation

class Loading
{
    static func loadFromLastFolder()
    {
        guard let url = CodeFolder.lastURL else { return }
        
        load(from: url)
    }
    
    static func load(from folder: URL)
    {
        guard let codeFiles = CodeFolder(url: folder).loadFiles() else
        {
            return
        }
        
        CodeFileStore.shared.elements = codeFiles
        
        let analyzer = CodeFileAnalyzer(typeRetriever: SwiftASTTypeRetriever())
        
        let analytics = analyzer.analyze(CodeFileStore.shared.elements)
        
        for fileAnalytics in analytics
        {
            fileAnalytics.printDebug()
        }
        
        CodeFileAnalyticsStore.shared.set(elements: analytics)
    }
}
