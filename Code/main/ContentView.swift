import SwiftUI
import AppKit
import SwiftObserver
import SwiftLSP

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
                    Image(systemName: systemImageName(for: artifact.kind))
                        .foregroundColor(iconColor(for: artifact.kind))
                    
                    Text(artifact.displayName)
                        .fixedSize()
                        .font(.system(.title3, design: .for(artifact)))
                    
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
    
    private func iconColor(for artifactKind: CodeArtifact.Kind) -> Color
    {
        switch artifactKind
        {
        case .folder: return Color(NSColor.secondaryLabelColor)
        case .file: return .white
        case .symbol(let symbol): return iconColor(for: symbol)
        }
    }
    
    private func iconColor(for symbol: LSPDocumentSymbol) -> Color
    {
        guard let symbolKind = symbol.symbolKind else
        {
            return Color(NSColor.secondaryLabelColor)
        }
        
        switch symbolKind
        {
        case .File, .Module, .Package:
            return .white
        case .Class, .Interface, .Struct, .Enum:
            return Color(NSColor.systemPurple)
        case .Namespace:
            return Color(NSColor.systemOrange)
        case .Method, .Constructor, .Function:
            return Color(NSColor.systemBlue)
        case .Property, .Field, .EnumMember:
            return Color(NSColor.systemTeal)
        case .Variable, .Constant:
            return Color(NSColor.systemPink)
        case .String:
            return Color(NSColor.systemRed)
        case .Number, .Boolean, .Array, .Object, .Key, .Null, .Event, .Operator, .TypeParameter:
            return Color(NSColor.secondaryLabelColor)
        }
    }
    
    private func systemImageName(for artifactKind: CodeArtifact.Kind) -> String
    {
        switch artifactKind
        {
        case .folder: return "folder.fill"
        case .file: return "doc.fill"
        case .symbol(let symbol): return iconSystemImageName(for: symbol)
        }
    }
    
    private func iconSystemImageName(for symbol: LSPDocumentSymbol) -> String
    {
        guard let symbolKind = symbol.symbolKind else
        {
            return "questionmark.square.fill"
        }
        
        switch symbolKind
        {
        case .File:
            return "doc.fill"
        case .Module, .Package:
            return "shippingbox.fill"
        case .Class, .Interface, .Struct, .Enum:
            return "t.square.fill"
        case .Namespace:
            return "x.square.fill"
        case .Method, .Constructor, .Function:
            return "f.square.fill"
        case .Property, .Field, .EnumMember:
            return "p.square.fill"
        case .Variable:
            return "v.square.fill"
        case .Constant:
            return "c.square.fill"
        case .String:
            return "s.square.fill"
        case .Number, .Boolean, .Array, .Object, .Key, .Null, .Event, .Operator, .TypeParameter:
            return "square.fill"
        }
    }
    
    @StateObject private var viewModel = ContentViewModel()
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
