import SwiftUI
import AppKit
import SwiftObserver
import SwiftLSP

struct CodefaceViewPreview: PreviewProvider
{
    static var previews: some View
    {
        CodefaceView().previewDisplayName("CodefaceView")
    }
}

struct CodefaceView: View
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
                        ArtifactView(artifact: artifact)
                            .padding(CodeArtifact.Layout.padding)
                        
//                            TextEditor(text: .constant(codeFile.content))
//                                .font(.system(.body, design: .monospaced))
                    }
                    .navigationTitle(artifact.displayName)
                }
                label:
                {
                    HStack
                    {
                        Image(systemName: systemImageName(for: artifact.kind))
                            .foregroundColor(iconColor(for: artifact.kind))
                        
                        Text(artifact.displayName)
                            .font(.system(.title3, design: .for(artifact)))
                        
                        Spacer()
                        
                        if let loc = artifact.metrics?.linesOfCode
                        {
                            Text("\(loc)")
                                .foregroundColor(locColor(for: artifact))
                                .font(.system(.title3, design: .monospaced))
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .searchable(text: $searchTerm)
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
    
    @State var searchTerm = ""
    @StateObject private var viewModel = ArtifactViewModel()
    @State var selectedArtifact: CodeArtifact?
}

extension Font.Design {
    static func `for`(_ artifact: CodeArtifact) -> Font.Design {
        switch artifact.kind {
        case .symbol: return .monospaced
        default: return .default
        }
    }
}

func warningColor(for linesOfCode: Int) -> SwiftUI.Color
{
    if linesOfCode < 100 { return Color(NSColor.systemGreen) }
    else if linesOfCode < 200 { return Color(NSColor.systemYellow) }
    else if linesOfCode < 300 { return Color(NSColor.systemOrange) }
    else { return Color(NSColor.systemRed) }
}
