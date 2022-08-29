import SwiftUI
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
                size in
                
                Task
                {
                    withAnimation(.easeInOut(duration: 1))
                    {
//                        print("updating layout because size change")
                        
                        artifact.updateLayoutOfParts(forScopeSize: size,
                                                     ignoreSearchFilter: viewModel.isTypingSearch)
                        artifact.layoutDependencies()
                    }
                }
            }
            .onReceive(viewModel.$isTypingSearch)
            {
                _ in
                
                Task
                {
                    withAnimation(.easeInOut(duration: 1))
                    {
//                        print("updating layout because typing change")
                        
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
    @ObservedObject var viewModel: ProjectAnalysisViewModel
    @Environment(\.colorScheme) var colorScheme
}
