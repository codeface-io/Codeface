@MainActor
struct Search
{
    var barIsShown = false
    var fieldIsFocused = false
    var term = ""
    
    static let toggleAnimationDuration: Double = 0.15
    static let layoutAnimationDuration: Double = 1.0
    static let filterUpdateAnimationDuration: Double = 0.15
}
