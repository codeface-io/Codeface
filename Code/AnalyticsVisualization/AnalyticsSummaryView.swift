import UIToolz
import GetLaid
import AppKit
import SwiftObserver
import SwiftyToolz

class AnalyticsSummaryView: NSView, Observer
{
    // MARK: - Initialization
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        layoutSubviews()
        
        folderPathLabel.alignment = .right
        
        observeProjectClassMessenger()
        observeAnalyticsStoreIfExisting()
    }
    
    required init?(coder decoder: NSCoder) { nil }
    
    // MARK: - Observe Project
    
    private func observeProjectClassMessenger()
    {
        observe(Project.messenger)
        {
            if case .didSetActiveProject(let project) = $0
            {
                self.observeAnalyticsStoreIfExisting()
                self.storeDidModifyData(project?.analyticsStore)
            }
        }
    }
    
    private func observeAnalyticsStoreIfExisting()
    {
        (Project.active?.analyticsStore).forSome { observe(analyticsStore: $0) }
    }
    
    private func observe(analyticsStore store: CodeFileAnalyticsStore)
    {
        observe(store).select(.didModifyData)
        {
            [weak self, weak store] in
            
            store.forSome { self?.storeDidModifyData($0) }
        }
    }
    
    let receiver = Receiver()
    
    // MARK: - Subviews
    
    private func storeDidModifyData(_ store: CodeFileAnalyticsStore?)
    {
        let folderPath = Project.active?.rootFolder.path ?? ""
        folderPathLabel.stringValue = folderPath
        numbersLabel.stringValue = "\(store?.totalLinesOfCode ?? 0) lines of code in \(store?.elements.count ?? 0) Swift files"
    }
    
    private func layoutSubviews()
    {
        numbersLabel >> allButRight(topOffset: 10, leftOffset: 10, bottomOffset: -10)
        folderPathLabel >> allButLeft(topOffset: 10, bottomOffset: -10, rightOffset: -10)
        folderPathLabel.left >> numbersLabel.right.offset(10)
        folderPathLabel.width >> numbersLabel
    }
    
    private lazy var numbersLabel = addForAutoLayout(Label())
    private lazy var folderPathLabel = addForAutoLayout(Label())
}
