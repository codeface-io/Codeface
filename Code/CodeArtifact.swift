import SwiftLSP
import Foundation

extension CodeArtifact
{
    func generateMetricsRecursively()
    {
        switch kind {
        case .folder:
            var loc = 0
            for child in (parts ?? []) {
                child.generateMetricsRecursively()
                loc += child.metrics?.linesOfCode ?? 0
            }
            metrics = .init(linesOfCode: loc)
            
            parts?.sort { $0.metrics?.linesOfCode ?? 0 > $1.metrics?.linesOfCode ?? 0 }
            
        case .file(let codeFile):
            metrics = .init(linesOfCode: codeFile.content.numberOfLines)
        case .symbol:
            break
        }
    }
}

extension String
{
    var numberOfLines: Int
    {
        var result = 0
        
        enumerateLines { _, _ in result += 1 }
        
        return result
    }
}

extension CodeArtifact: Hashable
{
    static func == (lhs: CodeArtifact, rhs: CodeArtifact) -> Bool
    {
        // TODO: implement true equality instead of identity
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}

extension CodeArtifact
{
    convenience init(lspDocSymbol: LSPDocumentSymbol)
    {
        self.init(displayName: lspDocSymbol.name,
                  kind: .symbol(lspDocSymbol),
                  parts: lspDocSymbol.children.map(CodeArtifact.init))
    }
}

extension CodeArtifact
{
    convenience init(codeFolder: CodeFolder)
    {
        var parts = [CodeArtifact]()
        
        parts += codeFolder.files.map(CodeArtifact.init)
        parts += codeFolder.subfolders.map(CodeArtifact.init)
        
        self.init(displayName: codeFolder.name,
                  kind: .folder(codeFolder),
                  parts: parts)
    }
    
    convenience init(codeFile: CodeFile)
    {
        self.init(displayName: codeFile.name, kind: .file(codeFile))
    }
}

class CodeArtifact: Identifiable
{
    init(displayName: String, kind: Kind, parts: [CodeArtifact] = [])
    {
        self.displayName = displayName
        self.kind = kind
        self.parts = parts
    }
    
    let id = UUID().uuidString
    
    let displayName: String
    
    let kind: Kind
    enum Kind { case folder(CodeFolder), file(CodeFile), symbol(LSPDocumentSymbol) }
    
    var parts: [CodeArtifact]?
    
    var metrics: Metrics?
    
    struct Metrics
    {
        let linesOfCode: Int
    }
}
