import Foundation
import SwiftLSP

/// Namespace to get the actual processing off the main actor
@BackgroundActor
enum CodebaseProcessorSteps
{
    static func readFolder(from location: LSP.CodebaseLocation) throws -> CodeFolder?
    {
        try location.folder.mapSecurityScoped
        {
            guard let codeFolder = try CodeFolder($0, codeFileEndings: location.codeFileEndings) else
            {
                throw "Project folder contains no code files with the specified file endings\nFolder: \($0.absoluteString)\nFile endings: \(location.codeFileEndings)"
            }
            
            return codeFolder
        }
    }
    
    static func retrieveSymbolsAndReferences(for codebase: CodeFolder,
                                             from server: LSP.Server,
                                             codebaseRootFolder: URL) async throws -> CodeFolder
    {
        try await codebase.retrieveSymbolsAndReferences(from: server,
                                                        codebaseRootFolder: codebaseRootFolder)
    }
    
    static func generateArchitecture(from folder: CodeFolder) -> CodeFolderArtifact
    {
        CodeSymbolArtifact.symbolHash.removeAll()
        return CodeFolderArtifact(codeFolder: folder, scope: nil)
    }
    
    static func addSymbolDependencies(in architecture: CodeFolderArtifact)
    {
        architecture.addSymbolDependencies()
    }
    
    static func addHigherLevelDependencies(in architecture: CodeFolderArtifact)
    {
        architecture.addCrossScopeDependencies()
    }
}
