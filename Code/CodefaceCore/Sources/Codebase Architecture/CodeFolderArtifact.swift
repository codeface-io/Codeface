import Foundation
import SwiftNodes

public final class CodeFolderArtifact: Identifiable, Sendable
{
    public init(name: String, scope: (any CodeArtifact)?)
    {
        self.name = name
        self.scope = scope
    }
    
    // MARK: - Metrics
    
    public var metrics = Metrics()
    
    // MARK: - Graph Structure
    
    public weak var scope: (any CodeArtifact)?
    public var partGraph = Graph<CodeArtifact.ID, Part>()
    
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
        
        public func addPartDependency(from sourceID: ID, to targetID: ID)
        {
            codeArtifact.addPartDependency(from: sourceID, to: targetID)
        }
        
        public var intrinsicSizeInLinesOfCode: Int?
        {
            codeArtifact.intrinsicSizeInLinesOfCode
        }
        
        public func sort() { codeArtifact.sort() }
        public var parts: [any CodeArtifact] { codeArtifact.parts }
        public var scope: (any CodeArtifact)? { codeArtifact.scope }
        public var name: String { codeArtifact.name }
        public var kindName: String { codeArtifact.kindName }
        public var code: String? { codeArtifact.code }
        public var id: String { codeArtifact.id }
        
        // MARK: Actual Artifact
        
        var codeArtifact: any CodeArtifact
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
    public let name: String
}
