protocol TypeRetriever
{
    func topLevelTypes(in code: String) -> Set<String>?
    func referencedTypes(in code: String) -> Set<String>?
}
