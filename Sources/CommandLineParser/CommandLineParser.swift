import Foundation

public enum CommandLineParseError: Swift.Error {
    /// A flag could not be matched to an option
    case invalidOption(Character)
}

/// Parses CommandLine.arguments and returns options prefixed with dashes and pluses and a list of all 
/// arguments which were not options.
public class CommandLineParser<Dashes: CommandLineOptions, Pluses: CommandLineOptions> {
    
    /// Parses a list of arguments and returns all arguments which were not options, all options which were prefixed with dashes and all options which were prefixed with pluses.
    /// - throws: `CommandLineParseError.invalidOption` if the a given flag could not be associated to an option
    /// - returns: The list of all arguments which do not correspond to options (e.g. filenames), the options triggered by dashes (e.g. -a -b) and to pluses (e.g. +a +b). Nil if there are no particular arguments (the default first argument, the filename, is skipped)
    public static func parse(_ arguments: [String]) throws -> (arguments: [String], dashOptions: Dashes, plusOptions: Pluses)? {
        guard arguments.count > 1 else {
            return nil
        }
        var outArguments = [String]()
        var outDashes = Dashes()
        var outPluses = Pluses()
        for arg in arguments[1...] {
            if let first = arg.first {
                switch first { 
                case "-":
                    try extractOptions(&outDashes, optionChunk: arg)
                case "+":
                    try extractOptions(&outPluses, optionChunk: arg)
                default:
                    outArguments.append(arg)
                }
            }
        }
        return (arguments: outArguments, dashOptions: outDashes, plusOptions: outPluses)
    }
    
    /// Extract all options for a CommandLineOptions OptionsSet
    /// - parameter previous: The previous value of the option set (normally empty at start); it will be populated.
    /// - parameter optionChunk: The string of options (flags) which were prefixed with dash or plus
    /// - throws: `CommandLineParseError.invalidOption` a flag in the given chunk was invalid
    static func extractOptions<T: CommandLineOptions> (_ previous: inout T, optionChunk: String) throws {
        let optString = optionChunk.dropFirst()
        for opt in optString {
            previous = previous.union(try T.option(forCharacter: opt))
        }
    }
    
}
