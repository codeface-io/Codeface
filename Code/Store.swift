import SwiftObserver

class Store: Observable
{
    static let shared = Store()
    
    private init() {}
    
    var analytics = [CodeFileAnalytics]()
    {
        didSet { send(.didModifyData) }
    }
    
    var latestUpdate = Event.didNothing
    
    enum Event { case didNothing, didModifyData }
}
