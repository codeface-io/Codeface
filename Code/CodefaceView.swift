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
        _viewModel = StateObject(wrappedValue: CodeArtifactViewModel())
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
                    Group
                    {
                        switch mode
                        {
                        case .treeMap:
                            ArtifactContentView(artifact: artifact)
                                .drawingGroup()
                                .padding(CodeArtifact.Layout.padding)
                        case .code:
                            if let code = artifact.codeContent
                            {
                                TextEditor(text: .constant(code))
                                    .font(.system(.body, design: .monospaced))
                            }
                            else
                            {
                                VStack
                                {
                                    Label(artifact.displayName,
                                          systemImage: systemImageName(for: artifact.kind))
                                        .font(.system(.title))
                                    
                                    Text("Select a contained file or symbol to show their code.")
                                        .padding(.top)
                                }
                                .padding(CodeArtifact.Layout.padding)
                            }
                        }
                    }
                    .toolbar
                    {
                        DisplayModePicker(mode: $mode)
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

            Label("Select a code artifact from the list",
                  systemImage: "arrow.left")
                .padding()
                .font(.system(.title))
        }
        .searchable(text: $searchTerm)
    }
    
    @State var searchTerm = ""
    @StateObject private var viewModel: CodeArtifactViewModel
    @State var selectedArtifact: CodeArtifact?
    @SceneStorage("viewMode") private var mode: ViewMode = .treeMap
}

struct DisplayModePicker: View
{
    var body: some View
    {
        Picker("Display Mode", selection: $mode)
        {
            ForEach(ViewMode.allCases) { $0.label }
        }
        .pickerStyle(.segmented)
    }
    
    @Binding var mode: ViewMode
}

extension ViewMode
{
    var label: some View
    {
        let content = labelContent
        return Label(content.name, systemImage: content.systemImage)
    }
    
    var labelContent: (name: String, systemImage: String)
    {
        switch self
        {
        case .treeMap:
            return ("Tree Map", "rectangle.3.group")
        case .code:
            return ("Code", "chevron.left.forwardslash.chevron.right")
        }
    }
}

enum ViewMode: String, CaseIterable, Identifiable
{
    var id: Self { self }
    
    case treeMap, code
}

extension CodeArtifact
{
    var codeContent: String?
    {
        switch kind
        {
        case .folder: return nil
        case .file(let file): return file.content
        case .symbol(let symbol): return symbol.code
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