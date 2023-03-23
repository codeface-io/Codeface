import Foundation
import SwiftyToolz

func tryLog(_ action: () throws -> Void)
{
    do
    {
        try action()
    }
    catch
    {
        log(error: error.localizedDescription)
    }
}

func tryLog(_ action: @Sendable @escaping () async throws -> Void)
{
    Task
    {
        do
        {
            try await action()
        }
        catch
        {
            log(error: error.localizedDescription)
        }
    }
}
