import Foundation

extension URL
{
    func readText() throws -> String
    {
        try String(contentsOf: self, encoding: .utf8)
    }
    
    func write(text: String) throws
    {
        try text.write(to: self, atomically: true, encoding: .utf8)
    }
}
