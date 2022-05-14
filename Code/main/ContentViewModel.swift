import SwiftUI
import SwiftObserver
import SwiftyToolz

class ContentViewModel: SwiftUI.ObservableObject, Observer
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

func warningColor(for linesOfCode: Int) -> SwiftUI.Color
{
    if linesOfCode < 100 { return Color(NSColor.systemGreen) }
    else if linesOfCode < 200 { return Color(NSColor.systemYellow) }
    else if linesOfCode < 300 { return Color(NSColor.systemOrange) }
    else { return Color(NSColor.systemRed) }
}
