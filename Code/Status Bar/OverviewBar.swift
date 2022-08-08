import Combine

class OverviewBar: ObservableObject
{
    @Published var artifactVMStack = [ArtifactViewModel]()
}
