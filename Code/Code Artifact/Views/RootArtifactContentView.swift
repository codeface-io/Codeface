import SwiftUI

struct RootArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            geo in
            
            ArtifactContentView(artifact: artifact,
                                viewModel: viewModel,
                                ignoreSearchFilter: viewModel.isSearching)
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
    
    let artifact: CodeArtifact
    @ObservedObject var viewModel: Codeface
}
