import Foundation

extension CodeFolderArtifact: CodeArtifact
{
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
    
    // MARK: - Tree Structure
    
    public weak var scope: CodeArtifact?
    
    public var subfolders = [CodeFolderArtifact]()
    public var files = [CodeFileArtifact]()
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let codeFolderURL: URL
}
