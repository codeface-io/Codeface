import SwiftUI
import AppKit
import SwiftObserver
import SwiftLSP

struct CodefaceViewPreview: PreviewProvider
{
    static var previews: some View
    {
        CodefaceView(displayMode: .constant(.treeMap))
            .previewDisplayName("CodefaceView")
    }
}

struct CodefaceView: View
{
    init(displayMode: Binding<DisplayMode>)
    {
        _viewModel = StateObject(wrappedValue: CodeArtifactViewModel())
        _displayMode = displayMode
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
                        switch displayMode
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
                        DisplayModePicker(displayMode: $displayMode)
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
                Button(action: toggleSidebar)
                {
                    Image(systemName: "sidebar.leading")
                }
            }

            Label("Select a code artifact from the list",
                  systemImage: "arrow.left")
                .padding()
                .font(.system(.title))
        }
        .searchable(text: $searchTerm)
        .onChange(of: searchTerm)
        {
            newSearchTerm in
            
            withAnimation(.easeInOut)
            {
                viewModel.userTyped(searchTerm: newSearchTerm)
            }
        }
    }
    
    @State var searchTerm = ""
    @StateObject private var viewModel: CodeArtifactViewModel
    @State var selectedArtifact: CodeArtifact?
    @Binding var displayMode: DisplayMode
}

struct DisplayModePicker: View
{
    var body: some View
    {
        Picker("Display Mode", selection: $displayMode)
        {
            ForEach(DisplayMode.allCases) { $0.label }
        }
        .pickerStyle(.segmented)
    }
    
    @Binding var displayMode: DisplayMode
}

extension DisplayMode
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

enum DisplayMode: String, CaseIterable, Identifiable
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
        case .file(let file): return file.lines.joined(separator: "\n")
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
                    .font(.system(.title3, design: .default))
            }
        }
    icon:
        {
            Image(systemName: systemImageName(for: artifact.kind))
                .foregroundColor(isSelected ? .primary : iconColor(for: artifact.kind))
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
