import LSPServiceKit
import Combine
import SwiftyToolz

@MainActor
public class CodefaceViewModel: ObservableObject
{
    public init() {}
    
    public func loadLastProjectIfNoneIsActive()
    {
        if ProjectLocationPersister.hasPersistedLastProject, projectAnalysis == nil
        {
            loadLastActiveProject()
        }
    }
    
    public func loadLastActiveProject()
    {
        do
        {
            try setAndStartActiveAnalysis(with: ProjectLocationPersister.loadProjectConfig())
        }
        catch { log(error) }
    }
    
    public func loadNewActiveAnalysis(for project: ProjectLocation)
    {
        do
        {
            try setAndStartActiveAnalysis(with: project)
            try ProjectLocationPersister.persist(project)
        }
        catch { log(error) }
    }
    
    private func setAndStartActiveAnalysis(with project: ProjectLocation) throws
    {
        projectAnalysis?.selectedArtifact = nil
        
        Task
        {
            let analysis = try ProjectProcessor(projectLocation: project)
            projectAnalysis = await ProjectAnalysisViewModel(activeAnalysis: analysis)
            try await analysis.run()
        }
    }
    
    @Published public var projectAnalysis: ProjectAnalysisViewModel? = nil
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
