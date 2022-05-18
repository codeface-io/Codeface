import SwiftUI
import SwiftLSP

struct ArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            geo in
            
            if let parts = artifact.parts,
               !parts.isEmpty,
               artifact.preparePartsForLayout(inScopeOfSize: geo.size)
            {
                ZStack
                {
                    ForEach(parts.filter({ $0.passesSearchFilter }))
                    {
                        ArtifactView(artifact: $0)
                    }
                }
                .frame(width: geo.size.width,
                       height: geo.size.height)
            }
        }
    }
    
    @ObservedObject var artifact: CodeArtifact
}
