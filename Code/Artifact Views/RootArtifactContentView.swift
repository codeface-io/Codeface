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
                        artifact.updateLayoutOfParts(forScopeSize: geo.size,
                                                     ignoreSearchFilter: viewModel.isTypingSearch)
                        artifact.layoutDependencies()
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
