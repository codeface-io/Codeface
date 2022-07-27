import SwiftUI

struct ArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            contentGeometry in
            
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
    
    @ObservedObject var artifact: ArtifactViewModel
    let viewModel: Codeface
    let ignoreSearchFilter: Bool
}
