import XCTest
@testable import CommandLineParser

class ParserTests: XCTestCase {
    
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
    
    func testWithPluses() {
        do {
            // Remember that first argument is the command used
            let command = "command"
            let a1 = "affgi"
            let a2 = "afnvnvoa"
            
            guard let (arguments, dashOptions, plusOptions) = try CommandLineParser<myOptsD, myOptsP>.parse([command, a1, "-a", "+d", "-b", a2]) else {
                XCTFail("Returned triple should not be nil")
                return
            }
            
            XCTAssertTrue(dashOptions.contains(.lettera))
            XCTAssertTrue(dashOptions.contains(.letterb))
            XCTAssertFalse(plusOptions.contains(.letterc))
            XCTAssertTrue(plusOptions.contains(.letterd))
            
            XCTAssertEqual(arguments[0], a1)
            XCTAssertEqual(arguments[1], a2)
            
        } catch CommandLineParseError.invalidOption(let char) {
            XCTFail("Invalid option: " + String(char))
        } catch {
            XCTFail("Unexpected error")
        }

    }
    
    func testOnlyDashes() {
        do {
            // Remember that first argument is the command used
            let command = "command"
            let a1 = "affgi"
            let a2 = "afnvnvoa"
            
            guard let _ = try CommandLineParser<myOptsD, myOptsD>.parse([command, a1, "-a", "+d", "-b", a2]) else {
                XCTFail("Returned triple should not be nil")
                return
            }
            
            XCTFail("The d option should cause an exception")
            
        } catch CommandLineParseError.invalidOption(let char) {
            // we should end up here
            XCTAssertEqual("d", char, "An invalid option exception should be thrown")
        } catch {
            XCTFail("Unexpected error")
        }
        
    }
}
