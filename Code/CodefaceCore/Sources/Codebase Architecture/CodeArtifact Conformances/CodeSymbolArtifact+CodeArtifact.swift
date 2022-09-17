import SwiftLSP

extension CodeSymbolArtifact: CodeArtifact
{
    public func sort()
    {
        subsymbolGraph.sort(by: <)
    }
    
    public var parts: [any CodeArtifact]
    {
        subsymbolGraph.nodesByValueID.values.map { $0.value }
    }
    
    public func addPartDependency(from sourceID: ID, to targetID: ID)
    {
        subsymbolGraph.addEdge(from: sourceID, to: targetID)
    }
    
    public var intrinsicSizeInLinesOfCode: Int? { (range.end.line - range.start.line) + 1 }
    
    public static var kindNames: [String] { LSPDocumentSymbol.SymbolKind.names }
    
    public var kindName: String { kind?.name ?? "Unknown Kind of Symbol" }
    
    // MARK: - Hashability
    
    public static func == (lhs: CodeSymbolArtifact,
                           rhs: CodeSymbolArtifact) -> Bool { lhs === rhs }
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
