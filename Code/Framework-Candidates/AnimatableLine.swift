import SwiftUI

/// how to draw an arrow: https://stackoverflow.com/questions/48625763/how-to-draw-a-directional-arrow-head
struct Line: Shape
{
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
        }
    }

    func path(in rect: CGRect) -> Path
    {
        Path
        {
            p in
            
            p.move(to: from)
            p.addLine(to: to)
        }
    }
    
    var from, to: CGPoint
}
