import Foundation
import SwiftLSP
import SwiftyToolz

public extension CodeFolder
{
    func retrieveSymbolsAndReferences(inParentFolderPath parentPath: String? = nil,
                                      from server: LSP.Server,
                                      codebaseRootFolder: URL) async throws -> CodeFolder
    {
        let parentPathWithSlash = parentPath?.appending("/") ?? ""
        let folderPath = parentPathWithSlash + name
        
        var resultingSubFolders = [CodeFolder]()
        
        for subfolder in (subfolders ?? [])
        {
            /// recursive call
            resultingSubFolders += try await subfolder.retrieveSymbolsAndReferences(inParentFolderPath: folderPath,
                                                                                    from: server,
                                                                                    codebaseRootFolder: codebaseRootFolder)
        }
        
        var resultingFiles = [CodeFile]()
        
        for file in (files ?? [])
        {
            let fileUri = CodeFolder.fileURI(forFilePath: folderPath + "/" + file.name,
                                             inRootFolder: codebaseRootFolder)
            
            try await server.notifyDidOpen(fileUri, containingText: file.code)
            
            let retrievedSymbols = try await server.requestSymbols(in: fileUri)
            
            var symbolDataArray = [CodeSymbol]()
            
            for retrievedSymbol in retrievedSymbols
            {
                symbolDataArray += try await CodeSymbol(lspDocumentSymbol: retrievedSymbol,
                                                        enclosingFile: fileUri,
                                                        codebaseRootPathAbsolute: codebaseRootFolder.absoluteString,
                                                        server: server)
            }
            
            /**
             this is where the magic happens: we create a new file instance in which the symbol data is not nil anymore. this quasi copying allows the symbols property to be constant and CodeFile and CodeFolder to be `Sendable`
             */
            resultingFiles += CodeFile(name: file.name,
                                       code: file.code,
                                       symbols: symbolDataArray)
        }
        
        return CodeFolder(name: name,
                          files: resultingFiles,
                          subfolders: resultingSubFolders)
    }
    
    private static func fileURI(forFilePath filePath: String,
                                inRootFolder rootFolder: URL) -> String
    {
        rootFolder.appendingPathComponent(filePath).absoluteString
    }
}
