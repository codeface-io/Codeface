import SwiftUI

class DisplayOptions: ObservableObject
{
    static let shared = DisplayOptions()
    
    @AppStorage("Show LoC in Navigator") var showLoC: Bool = false
    
    func switchDisplayMode()
    {
        switch displayMode
        {
        case .code: displayMode = .treeMap
        case .treeMap: displayMode = .code
        }
    }
    
    @Published public var displayMode: DisplayMode = .treeMap
}
