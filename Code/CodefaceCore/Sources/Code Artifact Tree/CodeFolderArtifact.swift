import Foundation
import SwiftyToolz

extension CodeFolderArtifact: CodeArtifact
{
    public func addDependency(from sourceArtifact: CodeArtifact,
                              to targetArtifact: CodeArtifact)
    {
        guard let sourceNode = getPartNode(for: sourceArtifact),
              let targetNode = getPartNode(for: targetArtifact)
        else
        {
            log(error: "Tried to add dependency to folder scope between invalid artifact types")
            return
        }
        
        // TODO: do sanity check that source and target actually contain subfolders or files of this folder
        
        partDependencies.addEdge(from: sourceNode, to: targetNode)
    }
    
    private func getPartNode(for artifact: CodeArtifact) -> PartNode?
    {
        switch artifact
        {
        case let folder as CodeFolderArtifact: return .init(kind: .subfolder(folder))
        case let file as CodeFileArtifact: return .init(kind: .file(file))
        default: return nil
        }
    }
    
    public var name: String { codeFolderURL.lastPathComponent }
    public var kindName: String { "Folder" }
    public var code: String? { nil }
}

@MainActor
public class CodeFolderArtifact: Identifiable, ObservableObject
{
    public init(codeFolder: CodeFolder, scope: CodeArtifact?)
    {
        self.codeFolderURL = codeFolder.url
        self.scope = scope
        
        self.subfolders = codeFolder.subfolders.map
        {
            CodeFolderArtifact(codeFolder: $0, scope: self)
        }
        
        self.files = codeFolder.files.map
        {
            CodeFileArtifact(codeFile: $0, scope: self)
        }
    }
    
    // MARK: - Metrics
    
    public var metrics = Metrics()
    
    // MARK: - Graph Structure
    
    public var partDependencies = Edges<PartNode>()
    
    public class PartNode: Hashable, Identifiable
    {
        init(kind: Kind)
        {
            self.kind = kind
        }
        
        public static func == (lhs: CodeFolderArtifact.PartNode,
                               rhs: CodeFolderArtifact.PartNode) -> Bool { lhs === rhs }
        
        public func hash(into hasher: inout Hasher)
        {
            hasher.combine(id)
        }
        
        public var id: String
        {
            switch kind
            {
            case .file(let file): return file.id
            case .subfolder(let subfolder): return subfolder.id
            }
        }
        
        let kind: Kind
        
        enum Kind
        {
            case subfolder(CodeFolderArtifact), file(CodeFileArtifact)
        }
    }
    
    public weak var scope: CodeArtifact?
    public var subfolders = [CodeFolderArtifact]()
    public var files = [CodeFileArtifact]()
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let codeFolderURL: URL
}
