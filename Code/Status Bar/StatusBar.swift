import Combine

class StatusBar: ObservableObject
{
    var displayText: String
    {
        artifactVMStack.map { $0.codeArtifact.name }.joined(separator: " 〉")
    }
    
    @Published var artifactVMStack = [ArtifactViewModel]()
}
