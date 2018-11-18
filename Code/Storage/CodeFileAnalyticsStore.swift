import SwiftObserver

class CodeFileAnalyticsStore: Store<CodeFileAnalytics>, Observable
{
    static let shared = CodeFileAnalyticsStore()
    
    private override init() {}
    
    func set(analytics: [CodeFileAnalytics], path: String)
    {
        self.path = path
        
        set(elements: analytics)
    }
    
    func set(elements: [CodeFileAnalytics])
    {
        self.elements = elements
        self.elements.sort(by: .linesOfCode, ascending: false)
        
        updateTotalLinesOfCode()
        
        send(.didModifyData)
    }
    
    func sort(by dimension: CodeFileAnalytics.SortDimension,
              ascending: Bool)
    {
        elements.sort(by: dimension, ascending: ascending)
        send(.didModifyData)
    }
    
    private func updateTotalLinesOfCode()
    {
        totalLinesOfCode = 0
        
        for fileAnalytics in elements
        {
            totalLinesOfCode += fileAnalytics.linesOfCode
        }
    }
    
    private(set) var path = ""
    private(set) var totalLinesOfCode = 0
    
    var latestUpdate = Event.didNothing
    
    enum Event { case didNothing, didModifyData }
}
