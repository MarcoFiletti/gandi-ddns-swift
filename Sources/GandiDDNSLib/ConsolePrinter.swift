/// Simple logger than prints to console depending on log level
@MainActor
public class ConsolePrinter {

    /// Everything which is at most this level of verbosity will be outputted.
    public static var level = LogLevel.normal

    /// Prints the message if its verbosity is <= current verbosity level
    /// and the current setting is not silent.
    public static func print(_ message: String, _ messageLevel: LogLevel = .normal) {
        guard ConsolePrinter.level != .silent else { return }

        if messageLevel.rawValue <= ConsolePrinter.level.rawValue {
            Swift.print(message)
        }
    }
}

/// Level of verbosity of a message (in ascending order)
public enum LogLevel: Int, Sendable {
    /// Prints nothing (return codes different than 0 can be used to detect errors)
    case silent
    /// Only prints when IPs are updated
    case normal
    /// Prints every operation
    case verbose
}
