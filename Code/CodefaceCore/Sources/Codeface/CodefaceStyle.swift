import SwiftyToolz

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
