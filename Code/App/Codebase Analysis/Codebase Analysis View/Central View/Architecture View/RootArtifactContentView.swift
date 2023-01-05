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
                if artifact.showsContent
                {
                    ArtifactContentView(artifactVM: artifact,
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
                
//                print("attempt to layout \(artifact.codeArtifact.name) because size changed to \(newSize)")
                
                withAnimation(.easeInOut(duration: 1))
                {
                    artifact.updateLayout(forScopeSize: newSize.size,
                                          ignoreSearchFilter: analysis.search.fieldIsFocused)
                }
            }
            .onReceive(analysis.$search.map({ $0.term }).removeDuplicates().dropFirst())
            {
                newTerm in
                
                guard !analysis.search.fieldIsFocused else { return }
                
                withAnimation(.easeInOut(duration: 1))
                {
                    artifact.updateLayout(forScopeSize: geo.size.size,
                                          ignoreSearchFilter: true,
                                          forceUpdate: true)
                }
            }
            .onReceive(analysis.$search.map({ $0.fieldIsFocused }).removeDuplicates().dropFirst())
            {
                isTyping in
                
//                print("attempt to layout \(artifact.codeArtifact.name) because user \(isTyping ? "started" : "ended") typing")

                withAnimation(.easeInOut(duration: 1))
                {
                    artifact.updateLayout(forScopeSize: geo.size.size,
                                          ignoreSearchFilter: isTyping,
                                          forceUpdate: true)
                }
            }
            .onChange(of: artifact)
            {
                newArtifact in
                
//                print("attempt to layout new artifact \(newArtifact.codeArtifact.name)")
                
                newArtifact.updateLayout(forScopeSize: geo.size.size,
                                         ignoreSearchFilter: analysis.search.fieldIsFocused,
                                         forceUpdate: true)
            }
            .onAppear
            {
//                print("attempt to layout artifact \(artifact.codeArtifact.name) because view appeared")
                
                artifact.updateLayout(forScopeSize: geo.size.size,
                                      ignoreSearchFilter: analysis.search.fieldIsFocused,
                                      forceUpdate: true)
            }
        }
    }
    
    @ObservedObject var artifact: ArtifactViewModel
    var analysis: CodebaseAnalysis
    @Environment(\.colorScheme) var colorScheme
}

extension CGSize
{
    var size: Size { .init(width, height) }
}
