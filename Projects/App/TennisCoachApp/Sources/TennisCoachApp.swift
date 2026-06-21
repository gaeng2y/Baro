import AppFeature
import SwiftUI
import TennisCore

@main
struct TennisCoachApp: App {
    var body: some Scene {
        WindowGroup {
            AppFeatureView(pipeline: .preview)
        }
    }
}
