import Combine

class GlobalSettings: ObservableObject
{
    static let shared = GlobalSettings()
    
    private init() {}
    
    @Published var useCorrectAnimations = false
}
