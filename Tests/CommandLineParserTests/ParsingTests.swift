import Testing
@testable import CommandLineParser

struct myOptsD: CommandLineOptions {
    let rawValue: Int
    static let lettera = myOptsD(rawValue: 1 << 0)
    static let letterb = myOptsD(rawValue: 1 << 1)
    static let correspondingFlags = "ab"
}

struct myOptsP: CommandLineOptions {
    let rawValue: Int
    static let letterc = myOptsP(rawValue: 1 << 0)
    static let letterd = myOptsP(rawValue: 1 << 1)
    static let correspondingFlags = "cd"
}

@Test
func withPluses() throws {
    // Remember that first argument is the command used
    let command = "command"
    let a1 = "affgi"
    let a2 = "afnvnvoa"

    guard let (arguments, dashOptions, plusOptions) = try CommandLineParser<myOptsD, myOptsP>.parse([command, a1, "-a", "+d", "-b", a2]) else {
        Issue.record("Returned triple should not be nil")
        return
    }

    #expect(dashOptions.contains(.lettera))
    #expect(dashOptions.contains(.letterb))
    #expect(!plusOptions.contains(.letterc))
    #expect(plusOptions.contains(.letterd))

    #expect(arguments[0] == a1)
    #expect(arguments[1] == a2)
}

@Test
func onlyDashes() {
    do {
        // Remember that first argument is the command used
        let command = "command"
        let a1 = "affgi"
        let a2 = "afnvnvoa"

        let _ = try CommandLineParser<myOptsD, myOptsD>.parse([command, a1, "-a", "+d", "-b", a2])
        #expect(Bool(false), "The d option should cause an exception")
    } catch CommandLineParseError.invalidOption(let char) {
        #expect(char == "d", "An invalid option exception should be thrown")
    } catch {
        #expect(Bool(false), "Unexpected error")
    }
}
