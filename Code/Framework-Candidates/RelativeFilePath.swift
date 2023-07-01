import SwiftyToolz

struct RelativeFilePath
{
    func appendingStringToLastComponent(_ string: String) -> RelativeFilePath
    {
        var newComponents = components
        let lastIndex = newComponents.count - 1
        newComponents[lastIndex] = newComponents[lastIndex] + string
        return RelativeFilePath(newComponents)
    }
    
    static func +=(path: inout RelativeFilePath, component: String)
    {
        path = path + component
    }
    
    static func +(path: RelativeFilePath, component: String) -> RelativeFilePath
    {
        path.appending(component)
    }
    
    func appending(_ component: String) -> RelativeFilePath
    {
        RelativeFilePath(components + Self.validComponents(from: [component]))
    }
    
    static var root: RelativeFilePath { .init() }
    
    init(string: String)
    {
        self.init([string])
    }
    
    init(_ components: [String] = [])
    {
        self.components = Self.validComponents(from: components)
    }
    
    private static func validComponents(from components: [String]) -> [String]
    {
        components.reduce([])
        {
            // check each provided component for remaining slashes and split it there
            $0 + $1.components(separatedBy: "/")
        }
        .compactMap
        {
            // throw out empty strings
            $0.isEmpty ? nil : $0
        }
    }
    
    func contains(_ otherPath: RelativeFilePath) -> Bool
    {
        // if self is the root folder, it contains any other file and folder. otherwise, the other path must have self as prefix
        isRoot ? true : otherPath.components.starts(with: components)
    }
    
    var isRoot: Bool { components.isEmpty }
    
    var string: String { components.joined(separator: "/") }
    
    let components: [String]
}
