import SwiftLSP

extension CodeArtifact
{
    var name: String
    {
        switch kind
        {
        case .folder(let folderURL): return folderURL.lastPathComponent
        case .file(let file): return file.name
        case .symbol(let symbol): return symbol.name
        }
    }
    
    var kindName: String
    {
        switch kind
        {
        case .folder: return "Folder"
        case .file: return "File"
        case .symbol(let symbol): return symbol.kindName
        }
    }
    
    var code: String?
    {
        switch kind
        {
        case .folder: return nil
        case .file(let file): return file.code
        case .symbol(let symbol): return symbol.code
        }
    }
}

extension CodeFile
{
    var code: String { lines.joined(separator: "\n") }
}
