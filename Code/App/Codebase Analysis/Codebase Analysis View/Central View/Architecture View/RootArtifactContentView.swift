import SwiftUI
import SwiftyToolz

struct RootArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            geo in
            
            Group
            {
                if artifactVM.showsContent
                {
                    ArtifactContentView(artifactVM: artifactVM,
                                        pathBar: analysis.pathBar,
                                        ignoreSearchFilter: analysis.search.fieldIsFocused,
                                        bgBrightness: colorScheme == .dark ? 0 : 0.6)
                    .drawingGroup()
                }
                else
                {
                    VStack
                    {
                        Spacer()
                        
                        HStack
                        {
                            Spacer()
                            
                            Text("Couldn't find layout that fits within \(Int(geo.size.width))×\(Int(geo.size.height)) points")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .font(.title3)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
            }
            .onChange(of: geo.size)
            {
                newSize in
                
//                print("attempt to layout \(artifactVM.codeArtifact.name) because size changed to \(newSize)")
                
                withAnimation(.easeInOut(duration: 1))
                {
                    artifactVM.updateLayout(forScopeSize: newSize.size,
                                            ignoreSearchFilter: analysis.search.fieldIsFocused)
                }
            }
            .onChange(of: artifactVM)
            {
                newArtifact in
                
//                print("attempt to layout newly selected artifact \(newArtifact.codeArtifact.name)")
                
                newArtifact.updateLayout(forScopeSize: geo.size.size,
                                         ignoreSearchFilter: analysis.search.fieldIsFocused)
            }
            .onAppear
            {
//                print("attempt to layout artifact \(artifact.codeArtifact.name) because view appeared")
                
                artifactVM.updateLayout(forScopeSize: geo.size.size,
                                        ignoreSearchFilter: analysis.search.fieldIsFocused)
            }
        }
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
    var analysis: CodebaseAnalysis
    @Environment(\.colorScheme) var colorScheme
}

extension CGSize
{
    var size: Size { .init(width, height) }
}
