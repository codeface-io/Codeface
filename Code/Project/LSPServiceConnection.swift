import Foundation

class LSPServiceConnection: ObservableObject
{
    static let shared = LSPServiceConnection()
    private init() {}
    
    static let infoPageURL = URL(string: "https://www.flowtoolz.com/codeface/lspservice")!
    
    @Published var isWorking = false
}
