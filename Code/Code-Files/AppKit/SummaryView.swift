import AppKit
import UIToolz
import SwiftObserver

class SummaryView: NSView, Observer
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        label.constrainToParent(inset: 10)
        
        observe(Store.shared, select: .didModifyData)
        {
            [weak self] in
            
            guard let self = self else { return }
            
            let store = Store.shared
            
            self.label.stringValue = "\(store.folderPath)"
        }
    }
    
    required init?(coder decoder: NSCoder) { fatalError() }
    
    private lazy var label = addForAutoLayout(Label())
}
