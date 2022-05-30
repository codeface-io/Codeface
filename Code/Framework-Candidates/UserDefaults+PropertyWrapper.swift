import Foundation

@propertyWrapper
struct UserDefault<Value>
{
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value
    {
        get
        {
            container.object(forKey: key) as? Value ?? defaultValue
        }
        
        set
        {
            container.set(newValue, forKey: key)
        }
    }
}
