enum DisplayMode: String, CaseIterable, Identifiable
{
    var id: Self { self }
    
    case treeMap, code
}
