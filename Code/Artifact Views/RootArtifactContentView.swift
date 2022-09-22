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
                                bgBrightness: colorScheme == .dark ? 0 : 0.6)
            .drawingGroup()
            .onChange(of: geo.size)
            {
                newSize in
                
//                print("attempt to layout \(artifact.codeArtifact.name) because size changed to \(newSize)")
                
                withAnimation(.easeInOut(duration: 1))
                {
                    artifact.updateLayout(forScopeSize: newSize,
                                          ignoreSearchFilter: viewModel.isTypingSearch)
                }
            }
            .onReceive(viewModel.$appliedSearchTerm.removeDuplicates().dropFirst())
            {
                newTerm in
                
//                print("attempt to layout \(artifact.codeArtifact.name) because search term changed to " + (newTerm ?? "nil"))

                withAnimation(.easeInOut(duration: 1))
                {
                    artifact.updateLayout(forScopeSize: geo.size,
                                          ignoreSearchFilter: viewModel.isTypingSearch,
                                          forceUpdate: true)
                }
            }
            .onReceive(viewModel.$isTypingSearch.removeDuplicates().dropFirst())
            {
                isTyping in
                
//                print("attempt to layout \(artifact.codeArtifact.name) because user \(isTyping ? "started" : "ended") typing")

                withAnimation(.easeInOut(duration: 1))
                {
                    artifact.updateLayout(forScopeSize: geo.size,
                                          ignoreSearchFilter: isTyping,
                                          forceUpdate: true)
                }
            }
            .onAppear
            {
//                print("attempt to layout \(artifact.codeArtifact.name) because view did appear")
                
                artifact.updateLayout(forScopeSize: geo.size,
                                      ignoreSearchFilter: viewModel.isTypingSearch,
                                      forceUpdate: true)
            }
        }
    }
    
    let artifact: ArtifactViewModel
    var viewModel: ProjectProcessorViewModel
    @Environment(\.colorScheme) var colorScheme
}
