import SwiftLSP

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
