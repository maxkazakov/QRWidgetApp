
import XCTest

final class WifiRegexTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let wifiPayload = #"WIFI:T:WPA;P:pasdfsdf   s""word:S:so\dfgdf dfgmessid;;"#

        if #available(iOS 16.0, *) {
            let wifiRegex = /WIFI:S:(?<ssid>.*);T:(?<type>.*);P:(?<password>.*);;/
            if let result = try? wifiRegex.wholeMatch(in: wifiPayload) {
                XCTAssertEqual(result.ssid, #"so\dfgdf dfgmessid"#)
                XCTAssertEqual(result.type, "WPA")
                XCTAssertEqual(result.password, #"pasdfsdf   s""word"#)
            }
        } else {

        }
    }

    func test_iOS15() throws {
        let wifiPayload = #"WIFI:T:WPA;P:pasdfsdf   s""word:S:so\dfgdf dfgmessid;;"#
        let pattern = #"WIFI:S:(?<ssid>.*);T:(?<type>.*);P:(?<password>.*);;"#
        let regex = try NSRegularExpression(pattern: pattern, options: [])

        let nsrange = NSRange(
            wifiPayload.startIndex..<wifiPayload.endIndex,
            in: wifiPayload
        )
        regex.enumerateMatches(
            in: wifiPayload,
            options: [],
            range: nsrange
        ) { match, _, stop in
            guard let match = match else { return }

            if match.numberOfRanges == 4,
               let ssidRange = Range(match.range(at: 1), in: wifiPayload),
               let typeRange = Range(match.range(at: 2), in: wifiPayload),
               let passwordRange = Range(match.range(at: 3), in: wifiPayload)
            {
                let ssid = wifiPayload[ssidRange]
                let type = wifiPayload[typeRange]
                let password = wifiPayload[passwordRange]

                XCTAssertEqual(ssid, #"so\dfgdf dfgmessid"#)
                XCTAssertEqual(type, "WPA")
                XCTAssertEqual(password, #"pasdfsdf   s""word"#)

                stop.pointee = true
            }
        }
    }

}
