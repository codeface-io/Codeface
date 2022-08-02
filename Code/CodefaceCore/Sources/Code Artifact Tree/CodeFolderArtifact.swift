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
    
    // Mark: - Metrics
    
    public var metrics = Metrics()
    
    // Mark: - Tree Structure
    
    public weak var scope: CodeArtifact?
    
    public var subfolders = [CodeFolderArtifact]()
    public var files = [CodeFileArtifact]()
    
    // Mark: - Basics
    
    public let id = UUID().uuidString
    public let codeFolderURL: URL
}
