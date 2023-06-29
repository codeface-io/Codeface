import SwiftLSP
import FoundationToolz
import SwiftyToolz

extension ArtifactIcon
{
    static var package: ArtifactIcon
    {
        .systemImage(name: "shippingbox.fill",
                     fillColor: .dynamic(.in(light: .bytes(167, 129, 79),
                                             darkness: .bytes(193, 156, 106))))
    }
    
    static var folder: ArtifactIcon
    {
        .systemImage(name: "folder.fill",
                     fillColor: .dynamic(.in(light: .bytes(19, 165, 235),
                                             darkness: .bytes(83, 168, 209))))
    }
    
    static func forFile(named fileName: String) -> ArtifactIcon
    {
        guard let fileEnding = fileName.components(separatedBy: ".").last,
              !fileEnding.isEmpty
        else
        {
            return .file
        }
        
        switch fileEnding
        {
        case "swift": return .swift
        case "dart": return .dart
        case "kt": return .kotlin
        default: return .file
        }
    }
    
    static var kotlin: ArtifactIcon
    {
        .imageName("kotlin")
    }
    
    static var dart: ArtifactIcon
    {
        .imageName("dart")
    }
    
    static var swift: ArtifactIcon
    {
        .systemImage(name: "swift",
                     fillColor: .rgba(.bytes(251, 139, 57)))
    }
    
    static var file: ArtifactIcon
    {
        .systemImage(name: "doc.fill",
                     fillColor: .rgba(.white))
    }
    
    static func `for`(symbolKind: LSPDocumentSymbol.SymbolKind?) -> ArtifactIcon
    {
        .systemImage(name: imageName(for: symbolKind),
                     fillColor: fillColor(for: symbolKind))
    }
    
    private static func imageName(for symbolKind: LSPDocumentSymbol.SymbolKind?) -> String
    {
        guard let symbolKind else { return "questionmark.square.fill" }
        
        switch symbolKind
        {
        case .File:
            return "doc.fill"
        case .Module, .Package:
            return "shippingbox.fill"
        case .Null:
            return "square.fill"
        default:
            if let firstCharacter = symbolKind.name.first?.lowercased()
            {
                return firstCharacter + ".square.fill"
            }
            else
            {
                return "questionmark.square.fill"
            }
        }
    }
    
    private static func fillColor(for symbolKind: LSPDocumentSymbol.SymbolKind?) -> UXColor
    {
        guard let symbolKind else { return .system(.secondaryLabel) }
        
        switch symbolKind
        {
        case .File, .Module, .Package:
            return .rgba(.white)
        case .Class, .Interface, .Struct:
            return .system(.purple)
        case .Namespace, .Enum:
            return .system(.orange)
        case .Method, .Constructor:
            return .system(.blue)
        case .Property, .Field, .EnumMember:
            return .system(.teal)
        case .Variable, .Constant, .Function, .Operator:
            return .system(.green)
        case .Number, .Boolean, .Array, .Object, .Key, .Null, .Event, .TypeParameter, .String:
            return .system(.secondaryLabel)
        }
    }
}

enum ArtifactIcon
{
    case systemImage(name: String, fillColor: UXColor)
    case imageName(String)
}
