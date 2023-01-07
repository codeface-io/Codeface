import Foundation
import SwiftNodes

final class CodeFolderArtifact: Identifiable, Sendable
{
    init(name: String, scope: (any CodeArtifact)?)
    {
        self.name = name
        self.scope = .init(artifact: scope)
    }

    // MARK: - Graph Structure
    
    let scope: ScopeReference
    let partGraph = Graph<CodeArtifact.ID, Part>()
    
    final class Part: CodeArtifact, Identifiable, Hashable
    {
        // MARK: Hashability
        
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
        static func == (lhs: Part, rhs: Part) -> Bool { lhs.id == rhs.id }
        
        // MARK: CodeArtifact Protocol
        
        func addPartDependency(from sourceID: ID, to targetID: ID)
        {
            codeArtifact.addPartDependency(from: sourceID, to: targetID)
        }
        
        var intrinsicSizeInLinesOfCode: Int?
        {
            codeArtifact.intrinsicSizeInLinesOfCode
        }
        
        func sort() { codeArtifact.sort() }
        var parts: [any CodeArtifact] { codeArtifact.parts }
        var scope: ScopeReference { codeArtifact.scope }
        var name: String { codeArtifact.name }
        var kindName: String { codeArtifact.kindName }
        var code: String? { codeArtifact.code }
        var id: String { codeArtifact.id }
        
        // MARK: Actual Artifact
        
        var codeArtifact: any CodeArtifact
        {
            switch kind
            {
            case .file(let file): return file
            case .subfolder(let subfolder): return subfolder
            }
        }
        
        init(kind: Kind) { self.kind = kind }
        
        let kind: Kind
        
        enum Kind
        {
            case subfolder(CodeFolderArtifact), file(CodeFileArtifact)
        }
    }
    
    // MARK: - Basics
    
    let id = UUID().uuidString
    let name: String
}
