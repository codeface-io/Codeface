import SwiftUI
import SwiftObserver

struct Preview: PreviewProvider
{
    static var previews: some View
    {
        ContentView().previewDisplayName("ContentView")
    }
}

struct ContentView: View
{
    var body: some View
    {
        NavigationView
        {
            List(viewModel.artifacts,
                 children: \.children,
                 selection: $selectedArtifact)
            {
                artifact in
                
                NavigationLink(tag: artifact,
                               selection: $selectedArtifact)
                {
                    Text(artifact.displayName)
                }
                label:
                {
                    Image(systemName: systemName(for: artifact.kind))
                    Text(artifact.displayName)
                }
            }
            .listStyle(.sidebar)
        }
    }
    
    @State var selectedArtifact: CodeArtifact?
    
    private func systemName(for articactKind: CodeArtifact.Kind) -> String
    {
        switch articactKind
        {
        case .folder: return "folder"
        case .file: return "doc"
        case .symbol: return "chevron.left.forwardslash.chevron.right"
        }
    }
    
    @StateObject private var viewModel = ContentViewModel()
}
