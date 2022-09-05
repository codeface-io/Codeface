import Foundation
import OrderedCollections
import SwiftyToolz

extension CodeFolderArtifact: CodeArtifact
{
    public func addDependency(from sourceArtifact: CodeArtifact,
                              to targetArtifact: CodeArtifact)
    {
        // FIXME: hash by content in the graph, ensure code artifact hash is the same as folder part hash ...
        guard let sourceNode = partGraph.nodes.first(where: { $0.content.codeArtifact.hash == sourceArtifact.hash }),
              let targetNode = partGraph.nodes.first(where: { $0.content.codeArtifact.hash == targetArtifact.hash })
        else
        {
            log(error: "Tried to add dependency to folder scope between artifacts for which no nodes are in the graph")
            return
        }
        
        partGraph.addEdge(from: sourceNode, to: targetNode)
    }
    
    public var name: String { codeFolderURL.lastPathComponent }
    public var kindName: String { "Folder" }
    public var code: String? { nil }
}

public class CodeFolderArtifact: Identifiable, ObservableObject
{
    public init(codeFolder: CodeFolder, scope: CodeArtifact?)
    {
        self.codeFolderURL = codeFolder.url
        self.scope = scope
        
        let partArray = codeFolder.subfolders.map
        {
            PartNode(kind: .subfolder(CodeFolderArtifact(codeFolder: $0,
                                                         scope: self)))
        }
        +
        codeFolder.files.map
        {
            PartNode(kind: .file(CodeFileArtifact(codeFile: $0,
                                                  scope: self)))
        }
        
        for part in partArray
        {
            partGraph.addNode(for: part)
        }
    }
    
    // MARK: - Metrics
    
    public var metrics = Metrics()
    
    // MARK: - Graph Structure
    
    public weak var scope: CodeArtifact?
    
    public var partGraph = Graph<PartNode>()
    
    public class PartNode: CodeArtifact, Hashable, Identifiable
    {
        // MARK: Initialize
        
        public init(kind: Kind)
        {
            self.kind = kind
        }
        
        // MARK: Hashable
        
        public static func == (lhs: CodeFolderArtifact.PartNode,
                               rhs: CodeFolderArtifact.PartNode) -> Bool { lhs === rhs }
        
        public func hash(into hasher: inout Hasher)
        {
            hasher.combine(id)
        }
        
        // MARK: CodeArtifact
        
        public var metrics: Metrics
        {
            get { codeArtifact.metrics }
            set { codeArtifact.metrics = newValue }
        }
        
        public var scope: CodeArtifact? { codeArtifact.scope }
        
        public func addDependency(from: CodeArtifact, to: CodeArtifact)
        {
            codeArtifact.addDependency(from: from, to: to)
        }
        
        public var name: String { codeArtifact.name }
        
        public var kindName: String { codeArtifact.kindName }
        
        public var code: String? { codeArtifact.code }
        
        public var id: String { codeArtifact.id }
        
        public var hash: CodeArtifact.Hash { codeArtifact.hash }
        
        var codeArtifact: CodeArtifact
        {
            switch kind
            {
            case .file(let file): return file
            case .subfolder(let subfolder): return subfolder
            }
        }
        
        // MARK: Actual Artifact
        
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
