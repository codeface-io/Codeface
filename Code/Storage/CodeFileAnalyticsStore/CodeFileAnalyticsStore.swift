import SwiftObserver

class CodeFileAnalyticsStore: Store<CodeFileAnalytics>, CustomObservable
{
    // MARK: - Singleton Instance
    
    static let shared = CodeFileAnalyticsStore()
    
    private override init() {}
    
    // MARK: - Analytics Elements
    
    func set(elements: [CodeFileAnalytics])
    {
        self.elements = elements
        self.elements.sort(by: .linesOfCode, ascending: false)
        
        updateTotalLinesOfCode()
        
        send(.didModifyData)
    }
    
    // MARK: - Sorting
    
    func sort(by dimension: CodeFileAnalytics.SortDimension,
              ascending: Bool)
    {
        elements.sort(by: dimension, ascending: ascending)
        send(.didModifyData)
    }
    
    // MARK: - Total Lines Of Code
    
    private func updateTotalLinesOfCode()
    {
        totalLinesOfCode = 0
        
        for fileAnalytics in elements
        {
            totalLinesOfCode += fileAnalytics.linesOfCode
        }
    }

    private(set) var totalLinesOfCode = 0
    
    // MARK: - Observability
    
    let messenger = Messenger(Event.didNothing)
    typealias Message = Event
    enum Event { case didNothing, didModifyData }
}
