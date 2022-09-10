import LSPServiceKit
import Combine
import SwiftyToolz

@MainActor
public class Codeface: ObservableObject
{
    public init() {}
    
    public func loadLastProjectIfNoneIsActive()
    {
        if ProjectLocationPersister.hasPersistedLastProjectLocation, projectProcessorVM == nil
        {
            loadLastProject()
        }
    }
    
    public func loadLastProject()
    {
        do
        {
            try setAndStartActiveProcessor(with: ProjectLocationPersister.loadProjectLocation())
        }
        catch { log(error) }
    }
    
    public func loadNewActiveprocessor(for project: ProjectLocation)
    {
        do
        {
            try setAndStartActiveProcessor(with: project)
            try ProjectLocationPersister.persist(project)
        }
        catch { log(error) }
    }
    
    private func setAndStartActiveProcessor(with location: ProjectLocation) throws
    {
        projectProcessorVM?.selectedArtifact = nil
        
        Task
        {
            let processor = try ProjectProcessor(location: location)
            projectProcessorVM = await ProjectProcessorViewModel(activeProcessor: processor)
            await processor.run()
        }
    }
    
    @Published public var projectProcessorVM: ProjectProcessorViewModel? = nil
}

public enum CodefaceStyle
{
    public static var accent: DynamicColor
    {
        .in(light: .bytes(0, 122, 255),
            darkness: .bytes(10, 132, 255))
    }
    
    public static var warningRed: DynamicColor
    {
        .in(light: .bytes(255, 59, 48),
            darkness: .bytes(255, 69, 58))
    }
}
