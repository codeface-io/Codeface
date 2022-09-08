import SwiftLSP
import Foundation
import SwiftNodes
import SwiftyToolz

extension CodeSymbolArtifact: CodeArtifact
{
    public func sort()
    {
        subsymbolGraph.sort(by: <)
    }
    
    public var parts: [CodeArtifact]
    {
        subsymbolGraph.nodesByValueID.values.map { $0.value }
    }
    
    public func addDependency(from source: CodeArtifact,
                              to target: CodeArtifact)
    {
        subsymbolGraph.addEdge(from: source.id, to: target.id)
    }
    
    public var intrinsicSizeInLinesOfCode: Int? { (range.end.line - range.start.line) + 1 }
    
    public static var kindNames: [String] { LSPDocumentSymbol.SymbolKind.names }
    
    public var kindName: String { kind?.name ?? "Unknown Kind of Symbol" }
}

extension CodeSymbolArtifact
{
    convenience init(symbolData: CodeSymbolData,
                     scope: CodeArtifact,
                     enclosingFile: CodeFile)
    {
        // base case: create this symbol
        let codeLines = enclosingFile.lines[symbolData.range.start.line ... symbolData.range.end.line]
        
        self.init(name: symbolData.name,
                  kind: symbolData.kind,
                  range: symbolData.range,
                  selectionRange: symbolData.selectionRange,
                  code: codeLines.joined(separator: "\n"),
                  scope: scope)
        
        // create subsymbols recursively
        for childSymbolData in symbolData.children
        {
            let childSymbol =  CodeSymbolArtifact(symbolData: childSymbolData,
                                                  scope: self,
                                                  enclosingFile: enclosingFile)
            
            subsymbolGraph.insert(childSymbol)
        }
        
        // remember symbol data, so we can add dependencies to the artifact hierarchy later
        symbolDataHash[self] = symbolData
    }
}

var symbolDataHash = [CodeSymbolArtifact: CodeSymbolData]()

public class CodeSymbolArtifact: Identifiable, Hashable, ObservableObject
{
    // MARK: - Initialization
    
    public init(name: String,
                kind: LSPDocumentSymbol.SymbolKind?,
                range: LSPRange,
                selectionRange: LSPRange,
                code: String,
                scope: CodeArtifact)
    {
        self.name = name
        self.kind = kind
        self.range = range
        self.selectionRange = selectionRange
        self.code = code
        self.scope = scope
    }
    
    // MARK: - Metrics
    
    public var metrics = Metrics()
    
    // MARK: - Graph Structure
    
    public weak var scope: CodeArtifact?
    
    public var subsymbolGraph = Graph<CodeSymbolArtifact>()
    
    public var outOfScopeDependencies = Set<CodeSymbolArtifact>()
    
    public static func == (lhs: CodeSymbolArtifact,
                           rhs: CodeSymbolArtifact) -> Bool { lhs === rhs }
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let name: String
    public let kind: LSPDocumentSymbol.SymbolKind?
    public let range: LSPRange
    public let selectionRange: LSPRange
    public let code: String?
}
