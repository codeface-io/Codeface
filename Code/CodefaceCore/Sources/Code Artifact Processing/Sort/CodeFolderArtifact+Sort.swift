public extension CodeFolderArtifact
{
    func sort()
    {
        for file in files
        {
            file.sort()
        }
        
        files.sort { $0.linesOfCode > $1.linesOfCode }
        
        for subfolder in subfolders
        {
            subfolder.sort()
        }
        
        subfolders.sort { $0.linesOfCode > $1.linesOfCode }
    }
}
