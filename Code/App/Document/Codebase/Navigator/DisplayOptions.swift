import SwiftUI

class DisplayOptions: ObservableObject
{
    static let shared = DisplayOptions()
    
    @AppStorage("Show LoC in Navigator") var showLoC: Bool = false
}
