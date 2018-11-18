import AppKit
import UIToolz

class AnalyticsView: LayerBackedView
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        layoutViews()
    }
    
    required init?(coder decoder: NSCoder) { fatalError() }
    
    private func layoutViews()
    {
        summary.constrainToParentExcludingBottom()
        
        table.constrainToParentExcludingTop()
        table.constrain(below: summary)
    }
    
    private lazy var summary = addForAutoLayout(AnalyticsSummaryView())
    private lazy var table = addForAutoLayout(ScrollTable<AnalyticsTable>())
}
