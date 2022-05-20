import SwiftUI

struct ArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            contentGeometry in
            
            if artifact.updateLayoutOfParts(forScopeSize: contentGeometry.size,
                                            ignoreSearchFilter: ignoreSearchFilter)
            {
                ZStack
                {
                    ForEach(artifact.filteredParts)
                    {
                        ArtifactView(artifact: $0,
                                     viewModel: viewModel,
                                     ignoreSearchFilter: ignoreSearchFilter)
                    }
                }
                .frame(width: contentGeometry.size.width,
                       height: contentGeometry.size.height)
            }
        }
    }
    
    @ObservedObject var artifact: CodeArtifact
    let viewModel: CodeArtifactViewModel
    let ignoreSearchFilter: Bool
}
