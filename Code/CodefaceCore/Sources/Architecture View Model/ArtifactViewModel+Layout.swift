import Foundation

public extension ArtifactViewModel
{
    func updateLayout(forScopeSize scopeSize: CGSize,
                      ignoreSearchFilter: Bool,
                      forceUpdate: Bool = false)
    {
        guard forceUpdate || scopeSize != lastScopeContentSize else { return }
        lastScopeContentSize = scopeSize
        
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
