import XCTest
@testable import TennisDomain

final class UserProfileTests: XCTestCase {
    func testDefaultProfileMatchesMVPDefaults() {
        let profile = UserProfile()

        XCTAssertEqual(profile.handedness, .right)
        XCTAssertEqual(profile.backhandType, .twoHanded)
        XCTAssertNil(profile.skillLevel)
        XCTAssertEqual(profile.feedbackFrequency, .normal)
    }
}
