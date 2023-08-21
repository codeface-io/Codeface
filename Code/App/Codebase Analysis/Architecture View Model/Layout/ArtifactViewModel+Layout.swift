import Foundation
import SwiftyToolz

extension ArtifactViewModel
{
    func updateLayout(forScopeSize scopeSize: Size? = nil,
                      ignoreSearchFilter: Bool)
    {
        guard let scopeSize = getScopeSize(forProvided: scopeSize) else
        {
            log(warning: "Tried to update layout but no proper scope size is available")
            return
        }
        
//        print("updating layout of \(codeArtifact.name)")
        
//        var stopWatch = StopWatch()
        updateLayoutOfParts(forScopeSize: scopeSize,
                            ignoreSearchFilter: ignoreSearchFilter)
//        stopWatch.measure("Artifact Layout")
        
//        stopWatch.restart()
        layoutDependencies()
//        stopWatch.measure("Dependency Layout")
        
        /**
         before any optimization: one layout of root folder, srckit-lsp, full screen:
         ⏱ Artifact Layout: 1.263375 mili seconds
         ⏱ Dependency Layout: 2.7165 mili seconds
         */
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
