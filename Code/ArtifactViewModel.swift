import SwiftUI
import SwiftObserver
import SwiftyToolz

class ArtifactViewModel: SwiftUI.ObservableObject, Observer
{
    init()
    {
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
