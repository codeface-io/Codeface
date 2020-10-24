import UIToolz
import GetLaid
import AppKit
import SwiftObserver

class AnalyticsSummaryView: NSView, Observer
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        layoutSubviews()
        
        folderPathLabel.alignment = .right
        
        observe(CodeFileAnalyticsStore.shared).select(.didModifyData)
        {
            [weak self] in self?.storeDidModifyData()
        }
    }
    
    private func storeDidModifyData()
    {
        let store = CodeFileAnalyticsStore.shared
        let folderPath = CodeFileLoading.lastFolder?.path ?? ""
        
        folderPathLabel.stringValue = "\(folderPath)"
        numbersLabel.stringValue = "\(store.totalLinesOfCode) lines of code in \(store.elements.count) Swift files"
    }
    
    private func layoutSubviews()
    {
        numbersLabel >> allButRight(topOffset: 10, leftOffset: 10, bottomOffset: -10)
        folderPathLabel >> allButLeft(topOffset: 10, bottomOffset: -10, rightOffset: -10)
        folderPathLabel.left >> numbersLabel.right.offset(10)
        folderPathLabel.width >> numbersLabel
    }
    
    required init?(coder decoder: NSCoder) { fatalError() }
    
    private lazy var numbersLabel = addForAutoLayout(Label())
    private lazy var folderPathLabel = addForAutoLayout(Label())
    
    let receiver = Receiver()
}
