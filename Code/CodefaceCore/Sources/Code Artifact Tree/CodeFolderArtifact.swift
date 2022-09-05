import Foundation
import OrderedCollections
import SwiftyToolz

extension CodeFolderArtifact: CodeArtifact
{
    public func addDependency(from sourceArtifact: CodeArtifact,
                              to targetArtifact: CodeArtifact)
    {
        partGraph.addEdge(from: sourceArtifact.id, to: targetArtifact.id)
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
            PartNodeValue(kind: .subfolder(CodeFolderArtifact(codeFolder: $0,
                                                              scope: self)))
        }
        +
        codeFolder.files.map
        {
            PartNodeValue(kind: .file(CodeFileArtifact(codeFile: $0,
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
    
    public var partGraph = Graph<PartNodeValue>()
    
    public class PartNodeValue: CodeArtifact, Identifiable
    {
        // MARK: Initialize
        
        public init(kind: Kind)
        {
            self.kind = kind
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
