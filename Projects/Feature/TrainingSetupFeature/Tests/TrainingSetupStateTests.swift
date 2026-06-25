import XCTest
@testable import TrainingSetupFeature
import TennisDomain

final class TrainingSetupStateTests: XCTestCase {
    func testDefaultStateRequiresCameraChecks() {
        let state = TrainingSetupState()

        XCTAssertFalse(state.isReadyToStart)
        XCTAssertEqual(state.cameraQuality, .bodyOutOfFrame)
    }

    func testCameraQualityFollowsFirstMissingReadinessCheck() {
        var state = TrainingSetupState(isBodyInFrame: true)
        XCTAssertEqual(state.cameraQuality, .lowLight)

        state.hasEnoughLight = true
        XCTAssertEqual(state.cameraQuality, .unstable)

        state.isPhoneStable = true
        XCTAssertTrue(state.isReadyToStart)
        XCTAssertEqual(state.cameraQuality, .ready)
    }

    func testInitialStrokeCanBeProvidedByQuickStart() {
        let state = TrainingSetupState(strokeType: .twoHandBackhand)

        XCTAssertEqual(state.strokeType, .twoHandBackhand)
        XCTAssertEqual(state.cameraMode, .side)
    }
}
