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
            List(viewModel.artifacts, id: \.id, children: \.children)
            {
                artifact in
                
                Image(systemName: systemName(for: artifact.kind))
                Text(artifact.displayName)
            }
            .listStyle(SidebarListStyle())
            
            Text("Huhu")
        }
    }
    
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

private class ContentViewModel: SwiftUI.ObservableObject, Observer
{
    init()
    {
        observe(Project.messenger)
        {
            switch $0
            {
            case .didCompleteAnalysis(let project):
                if project === Project.active,
                    let rootFolderArtifact = project.rootFolderArtifact {
                    self.artifacts = [rootFolderArtifact]
                }
            }
        }
    }
    
    @Published var artifacts = [CodeArtifact]()
    
    let receiver = Receiver()
}
