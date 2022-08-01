import SwiftUI

struct RootArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            geo in
            
            ArtifactContentView(artifactVM: artifact,
                                codeface: viewModel,
                                ignoreSearchFilter: viewModel.isSearching,
                                bgBrightness: 0.15)
            .onChange(of: geo.size)
            {
                size in
                
                Task
                {
                    withAnimation(.easeInOut(duration: 1))
                    {
                        artifact.updateLayoutOfParts(forScopeSize: size,
                                                     ignoreSearchFilter: viewModel.isSearching)
                    }
                }
            }
            .onReceive(viewModel.$isSearching)
            {
                _ in
                
                Task
                {
                    withAnimation(.easeInOut(duration: 1))
                    {
                        artifact.updateLayoutOfParts(forScopeSize: geo.size,
                                                     ignoreSearchFilter: viewModel.isSearching)
                    }
                }
            }
            .drawingGroup()
        }
    }
    
    let artifact: ArtifactViewModel
    @ObservedObject var viewModel: Codeface
}
