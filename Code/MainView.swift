import UIToolz
import SwiftyToolz

class MainView: LayerBackedView
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        backgroundColor = Color(0, 1.0, 0)
    }
    
    required init?(coder decoder: NSCoder) { fatalError() }
}
