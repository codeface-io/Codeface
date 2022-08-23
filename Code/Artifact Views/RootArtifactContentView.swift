import SwiftUI

struct RootArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            geo in
            
            ArtifactContentView(artifactVM: artifact,
                                pathBar: codeface.pathBar,
                                ignoreSearchFilter: codeface.isSearching,
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
                                                     ignoreSearchFilter: codeface.isSearching)
                        artifact.layoutDependencies()
                    }
                }
            }
            .onReceive(codeface.$isSearching)
            {
                _ in
                
                Task
                {
                    withAnimation(.easeInOut(duration: 1))
                    {
                        artifact.updateLayoutOfParts(forScopeSize: geo.size,
                                                     ignoreSearchFilter: codeface.isSearching)
                        artifact.layoutDependencies()
                    }
                }
            }
            .drawingGroup()
        }
    }
    
    let artifact: ArtifactViewModel
    @ObservedObject var codeface: Codeface
    @Environment(\.colorScheme) var colorScheme
}
