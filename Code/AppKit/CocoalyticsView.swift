import AppKit
import UIToolz

class CocoalyticsView: LayerBackedView
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        layoutTable()
    }
    
    required init?(coder decoder: NSCoder) { fatalError() }
    
    private func layoutTable()
    {
        table.constrainToParent()
    }
    
    private lazy var table = addForAutoLayout(ScrollTable<FileTable>())
}
