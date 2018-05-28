import Foundation

/// Command line options which can either be prefixed with `-` or `+` on the command line
public protocol CommandLineOptions: OptionSet {
    /// We define these options using Integers.
    /// (Needed since option(forCharacter:) inits using Int.).
    associatedtype RawValue: FixedWidthInteger
    
    /// Corresponding flags are in the same order of the options
    /// and are a single character (e.g. if we have two options, `n` for `.dry_run` and `v` for `.verbose` this field should be "nv")
    static var correspondingFlags: String { get }
}

public extension CommandLineOptions {
    /// Returns an option corresponding to a flag (e.g. returns `.dry_run` for the flag `n`).
    /// - throws: `CommandLineParseError.invalidOption` if the given flag was not found
    public static func option(forCharacter: Character) throws -> Self {
        for (n, char) in correspondingFlags.enumerated() {
            if forCharacter == char {
                return self.init(rawValue: 1 << n)
            }
        }
        throw CommandLineParseError.invalidOption(forCharacter)
    }
}

