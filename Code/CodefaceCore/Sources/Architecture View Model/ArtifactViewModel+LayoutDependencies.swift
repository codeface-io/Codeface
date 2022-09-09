import SwiftyToolz

public extension ArtifactViewModel
{
    func layoutDependencies()
    {
        applyRecursively
        {
            artifactVM in
            
            var tasksByOptimalX = [Double: [(Int, Dependency.LayoutTask.Range)]]()
            var tasksByOptimalY = [Double: [(Int, Dependency.LayoutTask.Range)]]()
            
            for dependencyIndex in artifactVM.partDependencies.indices
            {
                guard let task = artifactVM.partDependencies[dependencyIndex].calculateLayout() else
                {
                    continue
                }
                        
                switch task
                {
                case .horizontalRange(let horizontalRange):
                    tasksByOptimalX[horizontalRange.optimalA, default: []] += (dependencyIndex, horizontalRange)
                case .verticalRange(let verticalRange):
                    tasksByOptimalY[verticalRange.optimalA, default: []] += (dependencyIndex, verticalRange)
                }
            }
            
            for tasks in tasksByOptimalX.values
            {
                let numberOfTasks = tasks.count
                
                for taskIndex in tasks.indices
                {
                    let (dependencyIndex, horizontalRange) = tasks[taskIndex]
                    
                    let relativeXInRange = Double(taskIndex + 1) / Double(numberOfTasks + 1)
                    let rangeStart = horizontalRange.optimalA - horizontalRange.radiusA
                    let chosenX = rangeStart + relativeXInRange * (horizontalRange.radiusA * 2)
                    let sourcePoint = Point(chosenX, horizontalRange.sourceB)
                    let targetPoint = Point(chosenX, horizontalRange.targetB)
                    
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
                    let rangeStart = verticalRange.optimalA - verticalRange.radiusA
                    let chosenY = rangeStart + relativeYInRange * (verticalRange.radiusA * 2)
                    let sourcePoint = Point(verticalRange.sourceB, chosenY)
                    let targetPoint = Point(verticalRange.targetB, chosenY)
                    
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
    mutating func calculateLayout() -> LayoutTask?
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
            return .horizontalRange(.init(optimalA: sourceX,
                                          radiusA: radius,
                                          sourceB: sourceY,
                                          targetB: targetY))
        }
        else if sourceY == targetY
        {
            return .verticalRange(.init(optimalA: sourceY,
                                        radiusA: radius,
                                        sourceB: sourceX,
                                        targetB: targetX))
        }
        else
        {
            sourcePoint = Point(sourceX, sourceY)
            targetPoint = Point(targetX, targetY)
            return nil
        }
    }
    
    enum LayoutTask
    {
        case horizontalRange(Range)
        case verticalRange(Range)
        
        struct Range
        {
            let optimalA: Double
            let radiusA: Double
            
            let sourceB, targetB: Double
        }
    }
}
