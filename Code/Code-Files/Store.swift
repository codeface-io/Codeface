import SwiftObserver

class Store: Observable
{
    static let shared = Store()
    
    private init() {}
    
    func set(analytics: [CodeFileAnalytics], folderPath: String)
    {
        self.folderPath = folderPath
        self.analytics = analytics
        self.analytics.sortByLinesOfCode()
        send(.didModifyData)
    }
    
    func sortByLinesOfCode(ascending: Bool)
    {
        analytics.sortByLinesOfCode(ascending: ascending)
        send(.didModifyData)
    }
    
    func sortByFilePath(ascending: Bool)
    {
        analytics.sortByFilePath(ascending: ascending)
        send(.didModifyData)
    }
    
    private(set) var folderPath = ""
    private(set) var analytics = [CodeFileAnalytics]()
    
    var latestUpdate = Event.didNothing
    
    enum Event { case didNothing, didModifyData }
}
