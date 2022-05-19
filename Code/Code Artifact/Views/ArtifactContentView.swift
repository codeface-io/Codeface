import SwiftUI

struct ArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            contentGeometry in
            
            if artifact.updateLayoutOfParts(forScopeSize: contentGeometry.size)
            {
                ZStack
                {
                    ForEach(artifact.filteredParts)
                    {
                        ArtifactView(artifact: $0)
                    }
                }
                .frame(width: contentGeometry.size.width,
                       height: contentGeometry.size.height)
            }
        }
    }
    
    @ObservedObject var artifact: CodeArtifact
}
