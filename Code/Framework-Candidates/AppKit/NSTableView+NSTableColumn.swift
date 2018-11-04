import AppKit

extension NSTableView
{
    @discardableResult
    func addColumn(_ id: UIItemID,
                   sortable: Bool = true,
                   minWidth: CGFloat = 100) -> NSTableColumn
    {
        let column = NSTableColumn(identifier: id)
        column.resizingMask = .userResizingMask
        column.minWidth = minWidth
        column.title = id.rawValue
        
        if sortable
        {
            let sortDescriptor = NSSortDescriptor(key: id.rawValue,
                                                  ascending: true)
            column.sortDescriptorPrototype = sortDescriptor
        }
        
        addTableColumn(column)
        
        return column
    }
}

typealias UIItemID = NSUserInterfaceItemIdentifier
