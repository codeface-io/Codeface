import SwiftyToolz

struct RelativeFilePath
{
    static var root: RelativeFilePath { .init() }
    
    func appending(_ component: String) -> Self
    {
        RelativeFilePath(components + component)
    }
    
    init(string: String)
    {
        components = string.isEmpty ? [] : string.components(separatedBy: "/")
    }
    
    init(_ components: [String] = [])
    {
        self.components = components
    }
    
    func contains(_ otherPath: RelativeFilePath) -> Bool
    {
        // if self is the root folder, it contains any other file and folder. otherwise the other path must have self as prefix
        components.isEmpty ? true : otherPath.components.starts(with: components)
    }
    
    var string: String { components.joined(separator: "/") }
    
    let components: [String]
}
