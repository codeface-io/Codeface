import SwiftUI

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
