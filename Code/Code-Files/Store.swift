import SwiftObserver

class Store: Observable
{
    static let shared = Store()
    
    private init() {}
    
    func set(analytics: [CodeFileAnalytics], folderPath: String)
    {
        var sortingArray = analytics
        sortingArray.sortByLinesOfCode()
        self.folderPath = folderPath
        self.analytics = sortingArray
    }
    
    func sortByLinesOfCode(ascending: Bool)
    {
        analytics.sortByLinesOfCode(ascending: ascending)
    }
    
    func sortByFilePath(ascending: Bool)
    {
        analytics.sortByFilePath(ascending: ascending)
    }
    
    private(set) var folderPath = ""
    
    private(set) var analytics = [CodeFileAnalytics]()
    {
        didSet { send(.didModifyData) }
    }
    
    var latestUpdate = Event.didNothing
    
    enum Event { case didNothing, didModifyData }
}
