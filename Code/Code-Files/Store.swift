import SwiftObserver

class Store: Observable
{
    static let shared = Store()
    
    private init() {}
    
    func set(analytics: [CodeFileAnalytics], folderPath: String)
    {
        self.folderPath = folderPath
        self.analytics = analytics
        self.analytics.sort(by: .linesOfCode, ascending: false)
        send(.didModifyData)
    }
    
    func sort(by dimension: CodeFileAnalytics.SortDimension,
              ascending: Bool)
    {
        analytics.sort(by: dimension, ascending: ascending)
        send(.didModifyData)
    }
    
    private(set) var folderPath = ""
    private(set) var analytics = [CodeFileAnalytics]()
    
    var latestUpdate = Event.didNothing
    
    enum Event { case didNothing, didModifyData }
}
