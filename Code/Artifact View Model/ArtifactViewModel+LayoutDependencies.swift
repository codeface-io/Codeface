import SwiftyToolz

extension ArtifactViewModel
{
    func layoutDependencies()
    {
        applyRecursively
        {
            artifactVM in
            
            var tasksByOptimalX = [Double: [(Int, Dependency.LayoutResult.HorizontalRange)]]()
            var tasksByOptimalY = [Double: [(Int, Dependency.LayoutResult.VerticalRange)]]()
            
            for dependencyIndex in artifactVM.partDependencies.indices
            {
                let layout = artifactVM.partDependencies[dependencyIndex].calculateLayout()
                
                switch layout
                {
                case .points(let sourcePoint, let targetPoint):
                    artifactVM.partDependencies[dependencyIndex].sourcePoint = sourcePoint
                    artifactVM.partDependencies[dependencyIndex].targetPoint = targetPoint
                case .horizontalRange(let horizontalRange):
                    tasksByOptimalX[horizontalRange.optimalX, default: []] += (dependencyIndex, horizontalRange)
                case .verticalRange(let verticalRange):
                    tasksByOptimalY[verticalRange.optimalY, default: []] += (dependencyIndex, verticalRange)
                }
            }
            
            for tasks in tasksByOptimalX.values
            {
                let numberOfTasks = tasks.count
                
                for taskIndex in tasks.indices
                {
                    let (dependencyIndex, horizontalRange) = tasks[taskIndex]
                    
                    let relativeXInRange = Double(taskIndex + 1) / Double(numberOfTasks + 1)
                    let rangeStart = horizontalRange.optimalX - horizontalRange.radiusX
                    let chosenX = rangeStart + relativeXInRange * (horizontalRange.radiusX * 2)
                    let sourcePoint = Point(chosenX, horizontalRange.sourceY)
                    let targetPoint = Point(chosenX, horizontalRange.targetY)
                    
                    artifactVM.partDependencies[dependencyIndex].sourcePoint = sourcePoint
                    artifactVM.partDependencies[dependencyIndex].targetPoint = targetPoint
                }
            }
            
            for tasks in tasksByOptimalY.values
            {
                let numberOfTasks = tasks.count
                
                for taskIndex in tasks.indices
                {
                    let (dependencyIndex, verticalRange) = tasks[taskIndex]
                    
                    let relativeYInRange = Double(taskIndex + 1) / Double(numberOfTasks + 1)
                    let rangeStart = verticalRange.optimalY - verticalRange.radiusY
                    let chosenY = rangeStart + relativeYInRange * (verticalRange.radiusY * 2)
                    let sourcePoint = Point(verticalRange.sourceX, chosenY)
                    let targetPoint = Point(verticalRange.targetX, chosenY)
                    
                    artifactVM.partDependencies[dependencyIndex].sourcePoint = sourcePoint
                    artifactVM.partDependencies[dependencyIndex].targetPoint = targetPoint
                }
            }
        }
    }
}

@MainActor
extension ArtifactViewModel.Dependency
{
    func calculateLayout() -> LayoutResult
    {
        let sourceFrame = sourcePart.frameInScopeContent
        let targetFrame = targetPart.frameInScopeContent
        
        let sourceX, sourceY, targetX, targetY: Double
        
        var radius: Double = 0
        
        // x-axis
        if targetFrame.x > sourceFrame.maxX { // other is to the right
            sourceX = sourceFrame.maxX
            targetX = targetFrame.x
        } else if targetFrame.maxX < sourceFrame.x { // other is to the left
            sourceX = sourceFrame.x
            targetX = targetFrame.maxX
        } else { // other is horizontally overlapping (above or below)
            let rangeStart = max(targetFrame.x, sourceFrame.x)
            let rangeEnd = min(targetFrame.maxX, sourceFrame.maxX)
            sourceX = (rangeStart + rangeEnd) / 2
            targetX = sourceX
            radius = (rangeEnd - rangeStart) / 2
        }
        
        // y-axis
        if targetFrame.y > sourceFrame.maxY { // other is below
            sourceY = sourceFrame.maxY
            targetY = targetFrame.y
        } else if targetFrame.maxY < sourceFrame.y { // other is above
            sourceY = sourceFrame.y
            targetY = targetFrame.maxY
        } else { // other is vertically overlapping (to the left or right)
            let rangeStart = max(targetFrame.y, sourceFrame.y)
            let rangeEnd = min(targetFrame.maxY, sourceFrame.maxY)
            sourceY = (rangeStart + rangeEnd) / 2
            targetY = sourceY
            radius = (rangeEnd - rangeStart) / 2
        }
        
        if sourceX == targetX
        {
            return .horizontalRange(.init(optimalX: sourceX,
                                          radiusX: radius,
                                          sourceY: sourceY,
                                          targetY: targetY))
        }
        else if sourceY == targetY
        {
            return .verticalRange(.init(optimalY: sourceY,
                                        radiusY: radius,
                                        sourceX: sourceX,
                                        targetX: targetX))
        }
        else
        {
            return .points(Point(sourceX, sourceY), Point(targetX, targetY))
        }
    }
    
    enum LayoutResult
    {
        case points(Point, Point)
        case horizontalRange(HorizontalRange)
        case verticalRange(VerticalRange)
        
        struct HorizontalRange
        {
            let optimalX: Double
            let radiusX: Double
            
            let sourceY, targetY: Double
        }

        struct VerticalRange
        {
            let optimalY: Double
            let radiusY: Double
            
            let sourceX, targetX: Double
        }
    }
}

struct Point
{
    static let zero = Point(0, 0)
    
    init(_ x: Double, _ y: Double)
    {
        self.x = x
        self.y = y
    }
    
    let x, y: Double
}
