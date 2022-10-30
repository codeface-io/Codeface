import SwiftUI
import SwiftyToolz
import simd

struct ArrowPreview: PreviewProvider {
    static var previews: some View {
        ZStack {
            GeometryReader { geo in
                Arrow(from: CGPoint(x: geo.size.width,
                                    y: 0),
                      to: CGPoint(x: geo.size.width / 2 + 20,
                                  y: geo.size.height / 2),
                      size: 10)
                .stroke(style: .init(lineWidth: 3,
                                     lineCap: .round))
                .foregroundColor(.red.opacity(0.4))
            }
        }
    }
}

struct Arrow: Shape
{
    init(from: CGPoint, to: CGPoint, size: Double)
    {
        self.size = size
        
        self.from = from
        self.to = to
        
        (self.a, self.b) = Self.pathPointsAAndB(forArrowFrom: from,
                                                to: to,
                                                size: size)
        
        self.c = Self.arrowHeadPoints(forArrowFrom: self.a,
                                      to: self.b,
                                      size: size)
    }
    
    private static func pathPointsAAndB(forArrowFrom from: CGPoint,
                                        to: CGPoint,
                                        size: Double) -> (CGPoint, CGPoint)
    {
        let fromV = from.vector
        let toV = to.vector
        
        let padding = 4.0
        
        let normal = simd_normalize(toV - fromV)
        let reverseNormal = simd_normalize(fromV - toV)
        
        return (CGPoint(fromV + normal * size),
                CGPoint(toV + reverseNormal * padding))
    }
    
    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData>
    {
        get
        {
            AnimatablePair(from.animatableData, to.animatableData)
        }
        
        set
        {
            from.animatableData = newValue.first
            to.animatableData = newValue.second
            
            (a, b) = Self.pathPointsAAndB(forArrowFrom: from, to: to, size: size)
            
            c = Self.arrowHeadPoints(forArrowFrom: a, to: b, size: size)
        }
    }

    func path(in rect: CGRect) -> Path
    {
        Path
        {
            p in
            
            p.move(to: b)
            p.addLine(to: c.0)
            p.move(to: b)
            p.addLine(to: c.1)
            p.move(to: b)
            p.addLine(to: a)
            
            p.addEllipse(in: .init(x: from.x - size,
                                   y: from.y - size,
                                   width: 2 * size,
                                   height: 2 * size))
        }
    }
    
    let size: Double
    private var from, to: CGPoint
    private var a, b: CGPoint
    private var c: (CGPoint, CGPoint)
    
    private static func arrowHeadPoints(forArrowFrom pointA: CGPoint,
                                        to pointB: CGPoint,
                                        size: Double) -> (CGPoint, CGPoint)
    {
        let a = pointA.vector
        let b = pointB.vector
        
        let f = simd_normalize(a - b) // normalized vector pointing from b to a
        
        let length = 2.5 * size // length of the arrow head
        
        let d = b + (f * length)
        
        let f_orth_1 = Vector2D(-f.y, f.x) // 1st vector orthogonal to f
        let f_orth_2 = Vector2D(f.y, -f.x) // 2nd vector orthogonal to f
        
        let width = size // half width of the arrow head
        
        let c_1 = d + (width * f_orth_1)
        let c_2 = d + (width * f_orth_2)
        
        return (CGPoint(c_1), CGPoint(c_2))
    }
}

extension CGPoint
{
    init(_ vector: Vector2D)
    {
        self.init(x: vector.x, y: vector.y)
    }
    
    var vector: Vector2D { .init(x: x, y: y) }
}
