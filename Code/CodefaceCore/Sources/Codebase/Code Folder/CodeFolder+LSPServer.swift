import Foundation
import SwiftLSP
import SwiftyToolz

public extension CodeFolder
{
    static func retrieveSymbolsAndReferences(for folder: CodeFolder,
                                             inParentFolderPath parentPath: String? = nil,
                                             from server: LSP.Server,
                                             codebaseRootFolder: URL) async throws -> CodeFolder
    {
        let parentPathWithSlash = parentPath?.appending("/") ?? ""
        let folderPath = parentPathWithSlash + folder.name
        
        var resultingSubFolders = [CodeFolder]()
        
        for subfolder in (folder.subfolders ?? [])
        {
            /// recursive call
            resultingSubFolders += try await retrieveSymbolsAndReferences(for: subfolder,
                                                                inParentFolderPath: folderPath,
                                                                from: server,
                                                                codebaseRootFolder: codebaseRootFolder)
        }
        
        var resultingFiles = [CodeFile]()
        
        for file in (folder.files ?? [])
        {
            let fileUri = fileURI(forFilePath: folderPath + "/" + file.name,
                                  inRootFolder: codebaseRootFolder)
            
            try await server.notifyDidOpen(fileUri, containingText: file.code)
            
            let retrievedSymbols = try await server.requestSymbols(in: fileUri)
            
            var symbolDataArray = [CodeSymbolData]()
            
            for retrievedSymbol in retrievedSymbols
            {
                symbolDataArray += try await CodeSymbolData(lspDocumentSymbol: retrievedSymbol,
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
        
        return CodeFolder(name: folder.name,
                          files: resultingFiles,
                          subfolders: resultingSubFolders)
    }
    
    private static func fileURI(forFilePath filePath: String,
                                inRootFolder rootFolder: URL) -> String
    {
        rootFolder.appendingPathComponent(filePath).absoluteString
    }
}
