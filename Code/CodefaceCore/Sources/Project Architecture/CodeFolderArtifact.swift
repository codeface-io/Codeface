import Foundation
import SwiftNodes

public class CodeFolderArtifact: Identifiable
{
    internal init(scope: CodeArtifact?, codeFolderURL: URL)
    {
        self.scope = scope
        self.codeFolderURL = codeFolderURL
    }
    
    // MARK: - Metrics
    
    public var metrics = Metrics()
    
    // MARK: - Graph Structure
    
    public weak var scope: CodeArtifact?
    public var partGraph = Graph<Part>()
    
    public class Part: CodeArtifact, Identifiable, Hashable
    {
        // MARK: Hashability
        
        public func hash(into hasher: inout Hasher) { hasher.combine(id) }
        
        public static func == (lhs: Part, rhs: Part) -> Bool { lhs.id == rhs.id }
        
        // MARK: CodeArtifact Protocol
        
        public var metrics: Metrics
        {
            get { codeArtifact.metrics }
            set { codeArtifact.metrics = newValue }
        }
        
        public func addDependency(from: CodeArtifact, to: CodeArtifact)
        {
            codeArtifact.addDependency(from: from, to: to)
        }
        
        public var intrinsicSizeInLinesOfCode: Int?
        {
            codeArtifact.intrinsicSizeInLinesOfCode
        }
        
        public func sort() { codeArtifact.sort() }
        public var parts: [CodeArtifact] { codeArtifact.parts }
        public var scope: CodeArtifact? { codeArtifact.scope }
        public var name: String { codeArtifact.name }
        public var kindName: String { codeArtifact.kindName }
        public var code: String? { codeArtifact.code }
        public var id: String { codeArtifact.id }
        
        // MARK: Actual Artifact
        
        var codeArtifact: CodeArtifact
        {
            switch kind
            {
            case .file(let file): return file
            case .subfolder(let subfolder): return subfolder
            }
        }
        
        public init(kind: Kind) { self.kind = kind }
        
        public let kind: Kind
        
        public enum Kind
        {
            case subfolder(CodeFolderArtifact), file(CodeFileArtifact)
        }
    }
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let codeFolderURL: URL
}
