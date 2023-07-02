import Combine

class GlobalSettings: ObservableObject
{
    static let shared = GlobalSettings()
    
    private init() {}
    
    @Published var useCorrectAnimations = false
    
    #if DEBUG
    var updateSearchTermGlobally = true
    #else
    /// DO NOT TOUCH THIS (so we can't accidentally fuck up a release)
    var updateSearchTermGlobally = true
    #endif
}
