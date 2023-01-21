import Foundation
import SwiftNodes

final class CodeFolderArtifact: Identifiable, Sendable
{
    init(name: String,
         partGraph: Graph<CodeArtifact.ID, Part>)
    {
        self.name = name
        self.partGraph = partGraph
    }

    // MARK: - Graph Structure
    
    let partGraph: Graph<CodeArtifact.ID, Part>
    
    final class Part: CodeArtifact, Identifiable, Hashable
    {
        // MARK: Hashability
        
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
        static func == (lhs: Part, rhs: Part) -> Bool { lhs.id == rhs.id }
        
        // MARK: CodeArtifact Protocol
        
        var intrinsicSizeInLinesOfCode: Int?
        {
            codeArtifact.intrinsicSizeInLinesOfCode
        }
        
        var parts: [any CodeArtifact] { codeArtifact.parts }
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
