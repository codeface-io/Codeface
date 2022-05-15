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
    init()
    {
        _viewModel = StateObject(wrappedValue: ArtifactViewModel())
    }
    
    var body: some View
    {
        NavigationView
        {
            List(viewModel.artifacts,
                 children: \.parts,
                 selection: $selectedArtifact)
            {
                artifact in
                
                NavigationLink(tag: artifact, selection: $selectedArtifact)
                {
                    ArtifactContentView(artifact: artifact)
                        .drawingGroup()
                        .padding(CodeArtifact.Layout.padding)

                        .navigationTitle(artifact.displayName)
                        .navigationSubtitle(artifact.secondaryDisplayName)
//                        .toolbar
//                        {
//                            ToolbarItem(placement: .cancellationAction)
//                            {
//                                Button
//                                {
//
//                                } label:
//                                {
//                                    Image(systemName: "sidebar.trailing")
//                                }
//                            }
//                        }
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

//            Label("Select a code artifact from the list",
//                  systemImage: "arrow.left")
//                .padding()
//                .font(.system(.title))
//
//            TextEditor(text: .constant(selectedArtifact?.fileContentToShow ?? ""))
//                .font(.system(.body, design: .monospaced))
//                .frame(minWidth: 100)
        }
        .searchable(text: $searchTerm)
    }
    
    @State var searchTerm = ""
    @StateObject private var viewModel: ArtifactViewModel
    @State var selectedArtifact: CodeArtifact?
}

extension CodeArtifact
{
    var fileContentToShow: String?
    {
        if case .file(let file) = kind
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
                    .foregroundColor(isSelected ? .primary : artifact.locColor())
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
    
    
}

extension CodeArtifact
{
    func locColor() -> Color
    {
        switch kind
        {
        case .file:
            return warningColor(for: metrics?.linesOfCode ?? 0)
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
