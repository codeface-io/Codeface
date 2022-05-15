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
                        if let fileContent = artifact.fileContentToShow
                        {
                            TextEditor(text: .constant(fileContent))
                                .font(.system(.body, design: .monospaced))
                        }
                        else
                        {
                            ArtifactView(artifact: artifact)
                                .padding(CodeArtifact.Layout.padding)
                        }
                    }
                    .navigationTitle(artifact.displayName)
                    .navigationSubtitle(artifact.secondaryDisplayName)
                }
                label:
                {
                    SidebarLabel(artifact: artifact,
                                 isSelected: artifact === selectedArtifact)
                }
            }
            .listStyle(.sidebar)
            .toolbar
            {
                ToolbarItem(placement: .confirmationAction)
                {
                    Button(action: toggleSidebar)
                    {
                        Image(systemName: "sidebar.leading")
                    }
                }
            }
        }
        .searchable(text: $searchTerm)
    }
    
    @State var searchTerm = ""
    @StateObject private var viewModel = ArtifactViewModel()
    @State var selectedArtifact: CodeArtifact?
}

extension CodeArtifact
{
    var fileContentToShow: String?
    {
        if case .file(let file) = kind, parts?.isEmpty ?? true
        {
            return file.content
        }
        else
        {
            return nil
        }
    }
}

struct SidebarLabel: View
{
    var body: some View
    {
        Label
        {
            Text(artifact.displayName)
                .font(.system(.title3, design: .for(artifact)))

            if let loc = artifact.metrics?.linesOfCode
            {
                Spacer()

                Text("\(loc)")
                    .foregroundColor(isSelected ? .primary : locColor(for: artifact))
                    .font(.system(.title3, design: .monospaced))
            }
        }
        icon:
        {
            Image(systemName: systemImageName(for: artifact.kind))
                .accentColor(iconColor(for: artifact.kind))
        }
    }
    
    @State var artifact: CodeArtifact
    let isSelected: Bool
    
    private func locColor(for artifact: CodeArtifact) -> Color {
        switch artifact.kind {
        case .file:
            return warningColor(for: artifact.metrics?.linesOfCode ?? 0)
        default:
            return Color(NSColor.systemGray)
        }
    }
}

private func toggleSidebar()
{
    // https://stackoverflow.com/questions/61771591/toggle-sidebar-in-swiftui-navigationview-on-macos
    NSApp.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)),
                     to: nil,
                     from: nil)
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
