@globalActor public actor BackgroundActor
{
    /// Execute the given closure on this actor
    public static func run<T: Sendable>(resultType: T.Type = T.self,
                              body: @BackgroundActor @Sendable () async throws -> T) async rethrows -> T
    {
        try await body()
    }
    
    public static var shared = BackgroundActor()
}
