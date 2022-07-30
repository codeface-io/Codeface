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
                if artifact.filteredParts.count > 1
                {
                    Line(from: .init(x: artifact.filteredParts[0].frameInScopeContent.centerX,
                                     y: artifact.filteredParts[0].frameInScopeContent.centerY),
                         to: .init(x: artifact.filteredParts[1].frameInScopeContent.centerX,
                                   y: artifact.filteredParts[1].frameInScopeContent.centerY))
                    .stroke(lineWidth: 10)
                    .foregroundColor(.black)
                }
                
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
