import SwiftyToolz

public enum CodefaceStyle
{
    public static var warningRed: DynamicColor
    {
        .in(light: .rgba(0.95, 0, 0, 0.75),
            darkness: .rgba(1, 0, 0, 0.75))
    }
    
    public static var warningPurple: DynamicColor
    {
        .in(light: .rgba(0.9, 0, 0.9, 0.75),
            darkness: .rgba(0.95, 0, 0.95, 0.75))
    }
}
