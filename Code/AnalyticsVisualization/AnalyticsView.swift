import AppKit
import UIToolz
import GetLaid

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
        summary >> allButBottom
        table >> allButTop
        table.top >> summary.bottom
    }
    
    private lazy var summary = addForAutoLayout(AnalyticsSummaryView())
    private lazy var table = addForAutoLayout(ScrollTable<AnalyticsTable>())
}
