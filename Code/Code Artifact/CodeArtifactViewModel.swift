import SwiftUI
import Combine
import SwiftObserver
import SwiftyToolz

@MainActor
class CodeArtifactViewModel: SwiftUI.ObservableObject, Observer
{
    init()
    {
        if let rootArtifact = Project.shared?.analysisResult?.rootArtifact
        {
            self.artifacts = [rootArtifact]
        }
        
        observe(Project.messenger)
        {
            switch $0
            {
            case .didCompleteAnalysis(let analysisResult):
                self.artifacts = [analysisResult.rootArtifact]
            }
        }
    }
    
    func userTyped(searchTerm: String)
    {
        for artifact in artifacts
        {
            artifact.updateSearchResults(withSearchTerm: searchTerm)
            artifact.updateSearchFilter(allPass: false)
        }
    }
    
    @Published var artifacts = [CodeArtifact]()
    
    let receiver = Receiver()
}

extension CodeArtifact: Hashable
{
    static func == (lhs: CodeArtifact, rhs: CodeArtifact) -> Bool
    {
        // TODO: implement true equality instead of identity
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}
