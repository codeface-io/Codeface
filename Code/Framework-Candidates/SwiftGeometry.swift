struct Frame: Equatable
{
    static var zero: Frame { .init(centerX: 0, centerY: 0, width: 0, height: 0) }
    
    init(centerX: Double, centerY: Double, width: Double, height: Double)
    {
        self.centerX = centerX
        self.centerY = centerY
        self.width = width
        self.height = height
    }
    
    init(x: Double, y: Double, width: Double, height: Double)
    {
        self.centerX = x + width / 2
        self.centerY = y + height / 2
        self.width = width
        self.height = height
    }
    
    var x: Double { centerX - width / 2 }
    var y: Double { centerY - height / 2 }
    
    var maxX: Double { centerX + width / 2 }
    var maxY: Double { centerY + height / 2 }
    
    let centerX: Double
    let centerY: Double
    let width: Double
    let height: Double
}

struct Point
{
    static let zero = Point(0, 0)
    
    init(_ x: Double, _ y: Double)
    {
        self.x = x
        self.y = y
    }
    
    let x, y: Double
}
