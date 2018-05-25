/// Simple logger than prints to console depending on log level
public class Log {

    /// Everything which is at most this level of verbosity will be outputted.
    public static var level = LogLevel.normal

    /// Prints the message if its verbosity is <= current verbosity level
    /// and the current setting is not silent.
    public static func print(_ message: String, _ messageLevel: LogLevel = .normal) {
        guard Log.level != .silent else { return }

        if messageLevel.rawValue <= Log.level.rawValue {
            print(message)
        }
    }
}

/// Level of verbosity of a message (in ascending order)
public enum LogLevel: Int {
    /// Prints nothing (returns code different than 0 can be used to detect errors)
    case silent
    /// Only prints when IPs are updated
    case normal
    /// Prints every operation
    case verbose
}
