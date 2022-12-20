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
                                        ignoreSearchFilter: viewModel.searchVM.fieldIsFocused,
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
                                          ignoreSearchFilter: viewModel.searchVM.fieldIsFocused)
                }
            }
            .onReceive(viewModel.$searchVM.map({ $0.term }).removeDuplicates().dropFirst())
            {
                newTerm in
                
                guard !viewModel.searchVM.fieldIsFocused else { return }
                
                withAnimation(.easeInOut(duration: 1))
                {
                    artifact.updateLayout(forScopeSize: geo.size.size,
                                          ignoreSearchFilter: true,
                                          forceUpdate: true)
                }
            }
            .onReceive(viewModel.$searchVM.map({ $0.fieldIsFocused }).removeDuplicates().dropFirst())
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
                                         ignoreSearchFilter: viewModel.searchVM.fieldIsFocused,
                                         forceUpdate: true)
            }
            .onAppear
            {
//                print("attempt to layout artifact \(artifact.codeArtifact.name) because view appeared")
                
                artifact.updateLayout(forScopeSize: geo.size.size,
                                      ignoreSearchFilter: viewModel.searchVM.fieldIsFocused,
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
