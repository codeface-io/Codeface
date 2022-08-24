public enum DisplayMode: String, CaseIterable, Identifiable
{
    public var id: Self { self }
    
    case treeMap, code
}
