import SwiftUI

struct TreeMap: View
{
    var body: some View
    {
        if artifact.parts.isEmpty
        {
            VStack(alignment: .center)
            {
                Label("Empty Scope", systemImage: "xmark.rectangle")
                    .font(.system(.title))
                    .padding(.bottom)
                
                Text(artifact.codeArtifact.name + " contains no further symbols that could be detected.")
            }
            .foregroundColor(.secondary)
            .padding()
        }
        else
        {
            VStack(spacing: 0)
            {
                OverviewBarView(overviewBar: viewModel.overviewBar)
                
                RootArtifactContentView(artifact: artifact,
                                        codeface: viewModel)
                .padding(ArtifactViewModel.padding)
            }
            .background(Color(white: colorScheme == .dark ? 0 : 0.6))
        }
    }
    
    let artifact: ArtifactViewModel
    @ObservedObject var viewModel: Codeface
    @Environment(\.colorScheme) var colorScheme
}
