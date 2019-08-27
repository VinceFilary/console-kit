#if os(Linux)

<<<<<<< HEAD
import ConsoleKitTests

var tests = [XCTestCaseEntry]()
tests += ConsoleKitTests.__allTests()
=======
import XCTest
@testable import ConsoleTests
@testable import CommandTests

XCTMain([
    testCase(ConsoleTests.allTests),
    testCase(CommandTests.allTests)
])
>>>>>>> parent of 74cfbea... Added changes from https://github.com/vapor/console/pull/93 (#94)

#endif