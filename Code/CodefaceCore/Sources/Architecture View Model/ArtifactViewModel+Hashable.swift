extension ArtifactViewModel: Hashable
{
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
    
    public nonisolated static func == (lhs: ArtifactViewModel,
                                       rhs: ArtifactViewModel) -> Bool
    {
        lhs.id == rhs.id
    }
}
