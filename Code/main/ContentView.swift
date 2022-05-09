import SwiftUI
import AppKit
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
                 children: \.parts,
                 selection: $selectedArtifact)
            {
                artifact in
                
                NavigationLink(tag: artifact,
                               selection: $selectedArtifact)
                {
                    Group
                    {
                        switch artifact.kind
                        {
                        case .file(let codeFile):
                            TextEditor(text: .constant(codeFile.content))
                                .font(.system(.body, design: .monospaced))
                        default:
                            Text(artifact.displayName)
                        }
                    }
                    .navigationTitle(artifact.displayName)
                }
                label:
                {
                    Image(systemName: systemName(for: artifact.kind))
                        .foregroundColor(symbolColor(for: artifact.kind))
                    
                    Text(artifact.displayName)
                        .fixedSize()
                    Spacer()
                    
                    if let loc = artifact.metrics?.linesOfCode
                    {
                        Text("\(loc)")
                            .fixedSize()
                            .foregroundColor(locColor(for: artifact))
                            .font(.system(.title3, design: .monospaced))
                    }
                }
            }
            .listStyle(.sidebar)
        }
    }
    
    private func locColor(for artifact: CodeArtifact) -> Color {
        switch artifact.kind {
        case .file:
            return warningColor(for: artifact.metrics?.linesOfCode ?? 0)
        default:
            return Color(NSColor.systemGray)
        }
    }
    
    private func symbolColor(for artifactKind: CodeArtifact.Kind) -> Color
    {
        switch artifactKind
        {
        case .folder: return Color(NSColor.secondaryLabelColor)
        case .file: return .white
        case .symbol: return Color(NSColor.systemPurple)
        }
    }
    
    private func systemName(for artifactKind: CodeArtifact.Kind) -> String
    {
        switch artifactKind
        {
        case .folder: return "folder.fill"
        case .file: return "doc.fill"
        case .symbol: return "c.square.fill"
        }
    }
    
    @StateObject private var viewModel = ContentViewModel()
    @State var selectedArtifact: CodeArtifact?
}
