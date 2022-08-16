import SwiftUI

struct Sidebar: View
{
    var body: some View
    {
        switch viewModel.analysisState
        {
        case .succeeded(let rootArtifact):
            List([rootArtifact],
                 children: \.children,
                 selection: $viewModel.selectedArtifact)
            {
                artifact in
                
                SidebarRow(artifactVM: artifact, viewModel: viewModel)
            }
            .listStyle(.sidebar)
            .toolbar
            {
                Button(action: toggleSidebar)
                {
                    Image(systemName: "sidebar.leading")
                }
            }
            .onReceive(viewModel.$isSearching)
            {
                if !$0 { dismissSearch() }
            }
            .onChange(of: isSearching)
            {
                [isSearching] isSearchingNow in
                
                if !isSearching, isSearchingNow
                {
                    viewModel.beginSearch()
                }
            }
        case .running:
            VStack {
                ProgressView()
                    .progressViewStyle(.circular)
                
                if let folderName = viewModel.activeProject?.config.folder.lastPathComponent {
                    Text("Loading code base:\n" + folderName)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }
            }
            .padding()
        case .stopped:
            Text("Load a code base\nvia the File menu")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding()
        case .failed(let errorMessage):
            Text("An error occured during analysis:\n" + errorMessage)
                .foregroundColor(Color(NSColor.systemRed))
                .padding()
        }
    }
    
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch
    
    @ObservedObject var viewModel: Codeface
}

extension ArtifactViewModel: Hashable
{
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}

private extension ArtifactViewModel
{
    var children: [ArtifactViewModel]?
    {
        parts.isEmpty ? nil : parts
    }
}
