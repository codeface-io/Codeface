import SwiftUI
import simd

struct Arrow: View
{
    init(from a: CGPoint, to b: CGPoint)
    {
        self.a = a
        self.b = b
        self.c = Self.arrowHeadPoints(forArrowFrom: a, to: b)
    }
    
    var body: some View
    {
        Line(from: a, to: b).stroke(style: .init(lineWidth: 3, lineCap: .round))
        Line(from: c.0, to: b).stroke(style: .init(lineWidth: 3, lineCap: .round))
        Line(from: c.1, to: b).stroke(style: .init(lineWidth: 3, lineCap: .round))
    }
    
    let a, b: CGPoint
    private let c: (CGPoint, CGPoint)
    
    private static func arrowHeadPoints(forArrowFrom pointA: CGPoint,
                                        to pointB: CGPoint) -> (CGPoint, CGPoint)
    {
        let a = SIMD2<Double>(pointA.x, pointA.y)
        let b = SIMD2<Double>(pointB.x, pointB.y)
        
        let f = simd_normalize(a - b) // normalized vector pointing from b to a
        
        let length = 16.0 // length of the arrow head
        
        let d = b + (f * length)
        
        let f_orth_1 = SIMD2(-f.y, f.x) // 1st vector orthogonal to f
        let f_orth_2 = SIMD2(f.y, -f.x) // 2nd vector orthogonal to f
        
        let width = 5.0 // half width of the arrow head
        
        let c_1 = d + (width * f_orth_1)
        let c_2 = d + (width * f_orth_2)
        
        return (CGPoint(x: c_1.x, y: c_1.y), CGPoint(x: c_2.x, y: c_2.y))
    }
}
