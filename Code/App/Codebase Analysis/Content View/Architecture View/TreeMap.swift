import SwiftUI

struct TreeMap: View
{
    var body: some View
    {        
        RootArtifactContentView(artifact: rootArtifactVM, viewModel: viewModel)
            .padding(ArtifactViewModel.padding)
            .frame(minWidth: 300, minHeight: 300)
            .background(Color(white: colorScheme == .dark ? 0 : 0.6))
    }
    
    let rootArtifactVM: ArtifactViewModel
    @ObservedObject var viewModel: CodebaseProcessor
    @Environment(\.colorScheme) var colorScheme
}