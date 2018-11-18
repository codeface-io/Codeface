protocol TypeRetriever
{
    func topLevelTypes(in code: String) -> [String]?
    func referencedTypes(in code: String) -> [String]?
}
