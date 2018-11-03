import AppKit
import UIToolz

class MainView: LayerBackedView
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        layoutTable()
    }
    
    required init?(coder decoder: NSCoder) { fatalError() }
    
    private func layoutTable()
    {
        fileTable.constrainToParent()
    }
    
    private lazy var fileTable = addForAutoLayout(ScrollTable<FileTable>())
}
