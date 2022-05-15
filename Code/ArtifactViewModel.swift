import SwiftUI
import SwiftObserver
import SwiftyToolz

@MainActor
class ArtifactViewModel: SwiftUI.ObservableObject, Observer
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
    
    @Published var artifacts = [CodeArtifact]()
    
    let receiver = Receiver()
}
