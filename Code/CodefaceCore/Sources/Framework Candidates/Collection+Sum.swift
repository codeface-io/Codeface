public extension Collection
{
    func sum<Number: Numeric>(_ ofEach: (Element) -> Number) -> Number
    {
        reduce(0) { $0 + ofEach($1) }
    }
}
