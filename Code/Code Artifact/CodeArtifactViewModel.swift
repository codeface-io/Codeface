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
        
        observations += $searchTerm.sink
        {
            searchTerm in

            for artifact in self.artifacts
            {
                artifact.updateFilter(withSearchTerm: searchTerm)
            }
        }
    }
    
    @Published var artifacts = [CodeArtifact]()
    @Published var searchTerm = ""
    
    let receiver = Receiver()
    
    private var observations = [AnyCancellable]()
}
