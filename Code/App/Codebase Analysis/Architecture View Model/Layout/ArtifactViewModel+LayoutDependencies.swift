import SwiftyToolz

extension ArtifactViewModel
{
    func layoutDependencies()
    {
        applyRecursively
        {
            artifactVM in
            
            if !GlobalSettings.shared.useCorrectAnimations, !artifactVM.showsContent { return }
            
            var verticalTasks = [OrthogonalDependencyLayoutTask]()
            var horizontalTasks = [OrthogonalDependencyLayoutTask]()
            
            artifactVM.partDependencies
                .compactMap { $0.calculateLayout() }
                .forEach
                {
                    if $0.isVertical { verticalTasks += $0.task }
                    else { horizontalTasks += $0.task }
                }
                
            solve(verticalTasks, vertical: true)
            solve(horizontalTasks, vertical: false)
        }
    }
    
    private func solve(_ tasks: [OrthogonalDependencyLayoutTask], vertical: Bool)
    {
        var possiblyOverlappingTasksByOptimalA = [Double: [OrthogonalDependencyLayoutTask]]()
        
        for task in tasks
        {
            possiblyOverlappingTasksByOptimalA[task.centerA, default: []] += task
        }
        
        for possiblyOverlappingTasks in possiblyOverlappingTasksByOptimalA.values
        {
            var bucketsOfNonOverlappingTasks = [NonOverlappingTasks]()
            
            for task in possiblyOverlappingTasks.sorted(by: { $0.lengthB < $1.lengthB } )
            {
                var foundBucket = false
                
                for bucketIndex in bucketsOfNonOverlappingTasks.indices
                {
                    if bucketsOfNonOverlappingTasks[bucketIndex].add(newTask: task)
                    {
                        foundBucket = true
                        break
                    }
                }
                
                if !foundBucket
                {
                    bucketsOfNonOverlappingTasks += NonOverlappingTasks(tasks: [task])
                }
            }

            let numberOfPossiblyOverlappingBuckets = bucketsOfNonOverlappingTasks.count
            
            for bucketIndex in bucketsOfNonOverlappingTasks.indices
            {
                let relativeAInRange = Double(bucketIndex + 1) / Double(numberOfPossiblyOverlappingBuckets + 1)

                bucketsOfNonOverlappingTasks[bucketIndex].solve(relativeAInRange: relativeAInRange,
                                                                asVerticalTask: vertical)
            }
        }
    }
    
    private struct NonOverlappingTasks
    {
        func solve(relativeAInRange: Double, asVerticalTask: Bool)
        {
            for task in tasks
            {
                task.solve(relativeAInRange: relativeAInRange,
                           asVerticalTask: asVerticalTask)
            }
        }
        
        mutating func add(newTask: OrthogonalDependencyLayoutTask) -> Bool
        {
            if taskOverlapsWithExistingTasks(newTask: newTask) { return false }
            tasks += newTask
            return true
        }
        
        private func taskOverlapsWithExistingTasks(newTask: OrthogonalDependencyLayoutTask) -> Bool
        {
            for esistingTask in tasks
            {
                if esistingTask.rangeBOverlaps(with: newTask) { return true }
            }
            
            return false
        }
        
        var tasks: [OrthogonalDependencyLayoutTask]
    }
}

@MainActor
private extension DependencyVM
{
    func calculateLayout() -> DependencyLayoutResult?
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
            return .init(task: .init(centerA: sourceX,
                                     radiusA: radius,
                                     sourceB: sourceY,
                                     targetB: targetY,
                                     dependencyVM: self),
                         isVertical: false)
        }
        else if sourceY == targetY
        {
            return .init(task: .init(centerA: sourceY,
                                     radiusA: radius,
                                     sourceB: sourceX,
                                     targetB: targetX,
                                     dependencyVM: self),
                         isVertical: true)
        }
        else
        {
            sourcePoint = Point(sourceX, sourceY)
            targetPoint = Point(targetX, targetY)
            return nil
        }
    }
    
    struct DependencyLayoutResult
    {
        let task: OrthogonalDependencyLayoutTask
        let isVertical: Bool
    }
}

private struct OrthogonalDependencyLayoutTask
{
    var lengthB: Double
    {
        abs(targetB - sourceB)
    }
    
    func rangeBOverlaps(with otherTask: OrthogonalDependencyLayoutTask) -> Bool
    {
        !(max(otherTask.sourceB, otherTask.targetB) < min(sourceB, targetB)) &&
        !(min(otherTask.sourceB, otherTask.targetB) > max(sourceB, targetB))
    }
    
    func solve(relativeAInRange: Double, asVerticalTask isVertical: Bool)
    {
        let rangeA = radiusA * 2
        let rangeAStart = centerA - radiusA
        let resultA = rangeAStart + relativeAInRange * rangeA
        
        if isVertical
        {
            dependencyVM.sourcePoint = Point(sourceB, resultA)
            dependencyVM.targetPoint = Point(targetB, resultA)
        }
        else
        {
            dependencyVM.sourcePoint = Point(resultA, sourceB)
            dependencyVM.targetPoint = Point(resultA, targetB)
        }
    }
    
    let centerA: Double
    let radiusA: Double
    
    let sourceB, targetB: Double
    
    let dependencyVM: DependencyVM
}
