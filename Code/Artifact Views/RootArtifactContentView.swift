import SwiftUI
import FoundationToolz
import CodefaceCore

struct RootArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            geo in
            
            ArtifactContentView(artifactVM: artifact,
                                pathBar: viewModel.pathBar,
                                ignoreSearchFilter: viewModel.isTypingSearch,
                                bgBrightness: colorScheme == .dark ? 0 : 0.6,
                                isShownInScope: artifact.showsContent)
            .onChange(of: geo.size)
            {
                newSize in
                
                Task
                {
                    withAnimation(.easeInOut(duration: 1))
                    {
                        // print("updating layout because size change")
                        
                        artifact.updateLayoutOfParts(forScopeSize: newSize,
                                                     ignoreSearchFilter: viewModel.isTypingSearch)
                        artifact.layoutDependencies()
                    }
                }
            }
            .onReceive(viewModel.$selectedArtifact)
            {
                selectedArtifact in
                
                guard let selectedArtifact else { return }
                
//                 print("updating layout because selection change")
                
//                var stopWatch = StopWatch()
                selectedArtifact.updateLayoutOfParts(forScopeSize: geo.size,
                                                     ignoreSearchFilter: viewModel.isTypingSearch)
//                stopWatch.measure("Artifact Layout")
//                stopWatch.restart()
                selectedArtifact.layoutDependencies()
//                stopWatch.measure("Dependency Layout")
                
                /**
                 before any optimization: one layout of root folder, srckit-lsp, full screen:
                 ⏱ Artifact Layout: 49.851709 mili seconds
                 ⏱ Dependency Layout: 22.688292 mili seconds
                 */
            }
            .onReceive(viewModel.$isTypingSearch)
            {
                _ in
                
                Task
                {
                    withAnimation(.easeInOut(duration: 1))
                    {
//                        print("updating layout because typing change")
//
//                        let before = Double.uptimeNanoSeconds
                        
                        artifact.updateLayoutOfParts(forScopeSize: geo.size,
                                                     ignoreSearchFilter: viewModel.isTypingSearch)
                        artifact.layoutDependencies()
                        
//                        let after = Double.uptimeNanoSeconds
//
//                        let duration = after - before
//
//                        print ("\(Double(duration) / 1000000.0) ms")
                    }
                }
            }
            .drawingGroup()
        }
    }
    
    let artifact: ArtifactViewModel
    @ObservedObject var viewModel: ProjectProcessorViewModel
    @Environment(\.colorScheme) var colorScheme
}
