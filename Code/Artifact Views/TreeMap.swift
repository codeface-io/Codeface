import SwiftUI
import CodefaceCore

struct TreeMap: View
{
    var body: some View
    {
            VStack(spacing: 0)
            {
                PathBarView(overviewBar: viewModel.pathBar)
                
                RootArtifactContentView(artifact: rootArtifactVM,
                                        viewModel: viewModel)
                .padding(ArtifactViewModel.padding)
            }
            .background(Color(white: colorScheme == .dark ? 0 : 0.6))
    }
    
    let rootArtifactVM: ArtifactViewModel
    @ObservedObject var viewModel: ProjectAnalysisViewModel
    @Environment(\.colorScheme) var colorScheme
}

let lspServicePage = URL(string: "https://www.codeface.io/lspservice")!
