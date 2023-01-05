import SwiftyToolz

extension Sequence
{
    func asyncMap<Mapped>(_ transform: @Sendable (Element) async throws -> Mapped) async rethrows -> [Mapped]
    {
        // TODO: parallelize this using task group but maintaining order ... or is this rather an application of AsyncSequence???
        
        var result = [Mapped]()
        
        for element in self
        {
            result += try await transform(element)
        }
        
        return result
    }
}
