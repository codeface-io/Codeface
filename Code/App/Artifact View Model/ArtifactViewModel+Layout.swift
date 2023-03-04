import Foundation
import SwiftyToolz

extension ArtifactViewModel
{
    func updateLayout(forScopeSize optionalScopeSize: Size? = nil,
                      ignoreSearchFilter: Bool)
    {
        guard let scopeSize = optionalScopeSize ?? lastLayoutConfiguration?.scopeContentSize else
        {
            log(warning: "Tried to update layout but no scope size is available")
            return
        }
        
        let config = LayoutConfiguration(ignoreFilter: ignoreSearchFilter,
                                         scopeContentSize: scopeSize)
        
        guard config != lastLayoutConfiguration else { return }
        
        lastLayoutConfiguration = config
        
//        print("updating layout of \(codeArtifact.name)")
        
//        var stopWatch = StopWatch()
        updateLayoutOfParts(forScopeSize: scopeSize, ignoreSearchFilter: ignoreSearchFilter)
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
}
