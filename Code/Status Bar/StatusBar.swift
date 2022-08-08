import Combine

class StatusBar: ObservableObject
{
    var displayText: String
    {
        artifactNameStack.joined(separator: " 〉")
    }
    
    @Published var artifactNameStack = [String]()
}
