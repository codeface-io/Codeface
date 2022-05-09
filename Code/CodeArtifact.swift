import SwiftLSP
import Foundation

extension CodeArtifact
{
    func generateMetricsRecursively()
    {
        switch kind {
        case .folder:
            var loc = 0
            for child in (children ?? []) {
                child.generateMetricsRecursively()
                loc += child.metrics?.linesOfCode ?? 0
            }
            metrics = .init(linesOfCode: loc)
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

class CodeArtifact: Identifiable
{
    convenience init(codeFolder: CodeFolder)
    {
        var childArtifacts = [CodeArtifact]()
        
        childArtifacts += codeFolder.files.map(CodeArtifact.init)
        childArtifacts += codeFolder.subfolders.map(CodeArtifact.init)
        
        self.init(displayName: codeFolder.name,
                  kind: .folder(codeFolder),
                  children: childArtifacts.isEmpty ? nil : childArtifacts)
    }
    
    convenience init(codeFile: CodeFile)
    {
        self.init(displayName: codeFile.name, kind: .file(codeFile))
    }
    
    init(displayName: String, kind: Kind, children: [CodeArtifact]? = nil)
    {
        self.displayName = displayName
        self.kind = kind
        self.children = children
    }
    
    let id = UUID().uuidString
    
    let displayName: String
    
    let kind: Kind
    enum Kind { case folder(CodeFolder), file(CodeFile), symbol(LSPDocumentSymbol) }
    
    let children: [CodeArtifact]?
    
    var metrics: Metrics?
    
    struct Metrics
    {
        let linesOfCode: Int
    }
}
