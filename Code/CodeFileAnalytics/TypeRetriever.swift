protocol TypeRetriever
{
    func namesOfDeclaredTypes(in code: String) -> [String]?
    func namesOfReferencedTypes(in code: String) -> [String]?
}
