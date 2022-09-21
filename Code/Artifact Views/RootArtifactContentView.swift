import SwiftUI
import CodefaceCore

struct RootArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            geo in
            
            ArtifactContentView(artifactVM: artifact,
                                pathBar: viewModel.pathBar,
                                ignoreSearchFilter: viewModel.isTypingSearch,
                                bgBrightness: colorScheme == .dark ? 0 : 0.6,
                                isShownInScope: artifact.showsContent)
            .onChange(of: geo.size)
            {
                newSize in
                
                Task
                {
                    print("attempt to layout \(artifact.codeArtifact.name) because size changed to \(newSize)")
                    
                    withAnimation(.easeInOut(duration: 1))
                    {
                        artifact.updateLayout(forScopeSize: newSize,
                                              ignoreSearchFilter: viewModel.isTypingSearch)
                    }
                }
            }
            .onReceive(viewModel.$selectedArtifact.compactMap({ $0 }).removeDuplicates())
            {
//                print("attempt to layout because selection changed to: \($0.codeArtifact.name)")
                
                $0.updateLayout(forScopeSize: geo.size,
                                ignoreSearchFilter: viewModel.isTypingSearch)
            }
            .onReceive(viewModel.$appliedSearchTerm.removeDuplicates().dropFirst())
            {
                newTerm in
                
                Task
                {
                    withAnimation(.easeInOut(duration: 1))
                    {
//                        print("attempt to layout \(artifact.codeArtifact.name) because search term changed to " + (newTerm ?? "nil"))

                        artifact.updateLayout(forScopeSize: geo.size,
                                              ignoreSearchFilter: viewModel.isTypingSearch,
                                              forceUpdate: true)
                    }
                }
            }
            .onReceive(viewModel.$isTypingSearch.removeDuplicates().dropFirst())
            {
                isTyping in
                
                Task
                {
                    withAnimation(.easeInOut(duration: 1))
                    {
//                        print("attempt to layout \(artifact.codeArtifact.name) because user \(isTyping ? "started" : "ended") typing")

                        artifact.updateLayout(forScopeSize: geo.size,
                                              ignoreSearchFilter: isTyping)
                    }
                }
            }
            .drawingGroup()
        }
    }
    
    let artifact: ArtifactViewModel
    var viewModel: ProjectProcessorViewModel
    @Environment(\.colorScheme) var colorScheme
}
