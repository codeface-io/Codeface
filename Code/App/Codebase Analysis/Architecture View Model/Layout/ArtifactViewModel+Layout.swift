import Foundation
import SwiftyToolz

extension ArtifactViewModel
{
    /**
     Recursively updates the layout of all part boxes and dependency arrows within this artifact.
     
     It writes many properties of the contained parts, but most importantly `frameInScopeContent`, `contentFrame` and `showsParts`.
     */
    func updateLayout(forScopeSize scopeSize: Size? = nil,
                      applySearchFilter: Bool)
    {
        guard let scopeSize = getScopeSize(forProvided: scopeSize) else
        {
            log(warning: "Tried to update layout but no proper scope size is available")
            return
        }
        
        //        print("updating layout of \(codeArtifact.name)")
        
        //        var stopWatch = StopWatch()
        layoutParts(in: scopeSize,
                    applySearchFilter: applySearchFilter)
        //        stopWatch.measure("Artifact Layout")
        
        //        stopWatch.restart()
        layoutPartDependencies()
        //        stopWatch.measure("Dependency Layout")
    }
    
    private func getScopeSize(forProvided scopeSize: Size?) -> Size?
    {
        guard let scopeSize else
        {
            return lastLayoutScopeSize
        }
        
        guard scopeSize.width > 75 && scopeSize.height > 75 else
        {
            log(warning: "Invalid (small) view size: \(scopeSize). Gonna abort layout.")
            // invalid / untrue view sizes are reported by GeometryReader all the time – not just in the very beginning ... we can never set `showsContent = nil` (and show the loading spinner) based on that noise from SwiftUI ...
            return lastLayoutScopeSize
        }
        
        lastLayoutScopeSize = scopeSize
        
        return scopeSize
    }
}
