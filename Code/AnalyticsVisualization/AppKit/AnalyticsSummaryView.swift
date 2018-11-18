import AppKit
import UIToolz
import SwiftObserver

class AnalyticsSummaryView: NSView, Observer
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        layoutSubviews()
        
        folderPathLabel.alignment = .right
        
        observe(CodeFileAnalyticsStore.shared, select: .didModifyData)
        {
            [weak self] in self?.storeDidModifyData()
        }
    }
    
    private func storeDidModifyData()
    {
        let store = CodeFileAnalyticsStore.shared
        let folderPath = CodeFolder.lastURL?.path ?? ""
        
        folderPathLabel.stringValue = "\(folderPath)"
        numbersLabel.stringValue = "\(store.totalLinesOfCode) lines of code in \(store.elements.count) Swift files"
    }
    
    private func layoutSubviews()
    {
        numbersLabel.constrainToParentExcludingRight(inset: 10)
        folderPathLabel.constrainToParentExcludingLeft(inset: 10)
        folderPathLabel.constrain(toTheRightOf: numbersLabel, gap: 10)
        folderPathLabel.constrainWidth(to: numbersLabel)
    }
    
    required init?(coder decoder: NSCoder) { fatalError() }
    
    private lazy var numbersLabel = addForAutoLayout(Label())
    private lazy var folderPathLabel = addForAutoLayout(Label())
}
