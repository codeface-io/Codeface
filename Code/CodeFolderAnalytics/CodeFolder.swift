import SwiftObserver

class CodeFolder: Observable
{
    static let shared = CodeFolder()
    
    private init() {}
    
    func set(analytics: [CodeFileAnalytics], path: String)
    {
        self.path = path
        self.folderAnalytics = analytics
        self.folderAnalytics.sort(by: .linesOfCode, ascending: false)
        
        updateTotalLinesOfCode()
        
        send(.didModifyData)
    }
    
    func sort(by dimension: CodeFileAnalytics.SortDimension,
              ascending: Bool)
    {
        folderAnalytics.sort(by: dimension, ascending: ascending)
        send(.didModifyData)
    }
    
    private func updateTotalLinesOfCode()
    {
        totalLinesOfCode = 0
        
        for fileAnalytics in folderAnalytics
        {
            totalLinesOfCode += fileAnalytics.linesOfCode
        }
    }
    
    private(set) var path = ""
    private(set) var totalLinesOfCode = 0
    private(set) var folderAnalytics = [CodeFileAnalytics]()
    
    var latestUpdate = Event.didNothing
    
    enum Event { case didNothing, didModifyData }
}
