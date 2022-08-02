extension CodeFolder: CustomStringConvertible
{
    public var description: String
    {
        description(withPrefix: "")
    }
    
    private func description(withPrefix prefix: String) -> String
    {
        var result = prefix + url.lastPathComponent
        
        for file in files
        {
            result += "\n" + prefix + "    " + file.name
        }
        
        for folder in subfolders
        {
            result += "\n" + folder.description(withPrefix: prefix + "    ")
        }
        
        return result
    }
}
