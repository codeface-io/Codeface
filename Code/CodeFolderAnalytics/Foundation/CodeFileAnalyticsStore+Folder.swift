import Foundation

extension CodeFileAnalyticsStore
{
    func loadFromLastFolder()
    {
        guard let folder = CodeFolder.lastURL else { return }
        
        load(from: folder)
    }
    
    func load(from folder: URL)
    {
        CodeFileStore.shared.elements = CodeFolder(url: folder).loadFiles() ?? []
        
        let analyzer = CodeFileAnalyzer(typeRetriever: SwiftASTTypeRetriever())
        
        let analytics = analyzer.analyze(CodeFileStore.shared.elements)
        
        set(elements: analytics)
    }
}
