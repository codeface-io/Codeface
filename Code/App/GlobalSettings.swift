import Combine

class GlobalSettings: ObservableObject
{
    static let shared = GlobalSettings()
    
    private init() {}
    
    #if DEBUG
    @Published var useCorrectAnimations = true
    #else
    /// DO NOT TOUCH THIS (so we can't accidentally fuck up a release)
    @Published var useCorrectAnimations = false
    #endif
    
    #if DEBUG
    var updateSearchTermGlobally = false
    #else
    /// DO NOT TOUCH THIS (so we can't accidentally fuck up a release)
    var updateSearchTermGlobally = true
    #endif
    
    #if DEBUG
    var showPurchasePanel = false
    #else
    /// DO NOT TOUCH THIS (so we can't accidentally fuck up a release)
    var showPurchasePanel = true
    #endif
}
