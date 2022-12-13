import SwiftUI
import CodefaceCore
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
                                        pathBar: viewModel.pathBar,
                                        ignoreSearchFilter: viewModel.isTypingSearch,
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
                                          ignoreSearchFilter: viewModel.isTypingSearch)
                }
            }
            .onReceive(viewModel.$isTypingSearch.removeDuplicates().dropFirst())
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
            .onAppear
            {
//                print("attempt to layout \(artifact.codeArtifact.name) because view did appear")
                
                artifact.updateLayout(forScopeSize: geo.size.size,
                                      ignoreSearchFilter: viewModel.isTypingSearch,
                                      forceUpdate: true)
            }
        }
    }
    
    @ObservedObject var artifact: ArtifactViewModel
    var viewModel: ProjectProcessorViewModel
    @Environment(\.colorScheme) var colorScheme
}

extension CGSize
{
    var size: Size { .init(width, height) }
}
