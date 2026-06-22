import DesignSystem
import SwiftUI
import TennisDomain

public struct SessionSummaryFeatureState: Equatable {
    public var session: TrainingSession

    public init(session: TrainingSession) {
        self.session = session
    }
}

public enum SessionSummaryFeatureAction: Equatable {
    case save
    case delete
    case done
}

public struct SessionSummaryView: View {
    public var session: TrainingSession
    public var onDone: () -> Void

    public init(session: TrainingSession, onDone: @escaping () -> Void) {
        self.session = session
        self.onDone = onDone
    }

    public var body: some View {
        ZStack {
            LiquidGlassBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        StatusCapsule("SESSION SUMMARY", tone: .active)
                        Text("세션 요약")
                            .font(.largeTitle.weight(.heavy))
                    }

                    HStack {
                        MetricPill(title: "총 스윙", value: "\(summary.totalSwingCount)")
                        MetricPill(title: "분석 성공", value: "\(summary.analyzedSwingCount)")
                    }

                    CoachCard {
                        Text("반복 오류")
                            .font(.headline.weight(.heavy))
                        if summary.repeatedErrors.isEmpty {
                            Text("아직 분석 가능한 반복 오류가 부족합니다.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(summary.repeatedErrors) { error in
                                HStack {
                                    Text(error.cue.text)
                                        .font(.headline.weight(.bold))
                                    Spacer()
                                    StatusCapsule("\(error.count)회", tone: .warning)
                                }
                            }
                        }
                    }

                    CoachCard {
                        Text("다음 세션 목표")
                            .font(.headline.weight(.heavy))
                        Text(summary.recommendedFocus?.text ?? "전신이 화면에 들어오게 세팅하고 10회 이상 스윙해보세요.")
                            .font(.title3.weight(.heavy))
                    }

                    PrimaryCoachButton("완료", action: onDone)
                }
                .padding(20)
            }
        }
    }

    private var summary: SessionSummary {
        session.summary ?? SessionSummaryBuilder.build(from: session.swingEvents)
    }
}
