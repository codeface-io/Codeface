protocol CodeAnalyzer
{
    func namesOfDeclaredTypes(in code: String) -> [String]?
    func namesOfReferencedTypes(in code: String) -> [String]?
}

extension String
{
    var numberOfLines: Int
    {
        var result = 0
        
        enumerateLines { _, _ in result += 1 }
        
        return result
    }
}
