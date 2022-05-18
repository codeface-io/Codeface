extension CodeArtifact
{
    var name: String
    {
        switch kind
        {
        case .folder(let folder): return folder.name
        case .file(let file): return file.name
        case .symbol(let symbol): return symbol.lspDocumentSymbol.name
        }
    }
    
    var kindName: String
    {
        switch kind
        {
        case .folder: return "Folder"
        case .file: return "File"
        case .symbol(let symbol): return symbol.lspDocumentSymbol.kindName
        }
    }
    
    var code: String?
    {
        switch kind
        {
        case .folder: return nil
        case .file(let file): return file.lines.joined(separator: "\n")
        case .symbol(let symbol): return symbol.code
        }
    }
}
