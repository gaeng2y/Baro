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
                        MetricPill(title: "제외", value: "\(summary.failedSwingCount)")
                    }

                    CoachCard {
                        HStack {
                            Text("이번 세션 핵심")
                                .font(.headline.weight(.heavy))
                            Spacer()
                            StatusCapsule(focusBadge, tone: summary.recommendedFocus == nil ? .warning : .active)
                        }

                        Text(summary.recommendedFocus?.text ?? "분석 가능한 스윙을 더 모으면 핵심 cue를 추천할 수 있어요.")
                            .font(.title2.weight(.heavy))
                            .foregroundStyle(CoachTheme.primaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(focusGuide)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    CoachCard {
                        HStack {
                            Text("반복 오류")
                                .font(.headline.weight(.heavy))
                            Spacer()
                            StatusCapsule(analysisRateText, tone: .neutral)
                        }

                        if summary.repeatedErrors.isEmpty {
                            Text("아직 분석 가능한 반복 오류가 부족합니다.")
                                .foregroundStyle(.secondary)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(rankedErrors) { rankedError in
                                    RepeatedErrorRow(
                                        rank: rankedError.rank,
                                        error: rankedError.error,
                                        analyzedSwingCount: summary.analyzedSwingCount
                                    )
                                }
                            }
                        }
                    }

                    CoachCard {
                        Text("다음 세션 목표")
                            .font(.headline.weight(.heavy))
                        Text(nextSessionGoal)
                            .font(.title3.weight(.heavy))
                            .fixedSize(horizontal: false, vertical: true)
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

    private var topError: ErrorCount? {
        summary.repeatedErrors.first
    }

    private var focusBadge: String {
        if let topError {
            return "\(topError.count)회 반복"
        }
        return "데이터 부족"
    }

    private var focusGuide: String {
        guard topError != nil else {
            return "전신 프레임을 맞추고 10회 이상 스윙하면 반복 패턴을 더 안정적으로 잡을 수 있습니다."
        }
        return "다음 세션 첫 10회는 다른 피드백보다 이 cue 하나에만 집중하세요."
    }

    private var nextSessionGoal: String {
        guard let recommendedFocus = summary.recommendedFocus else {
            return "전신이 화면에 들어오게 세팅하고 10회 이상 스윙해보세요."
        }
        return "첫 랠리 전 \(recommendedFocus.text)"
    }

    private var analysisRateText: String {
        guard summary.totalSwingCount > 0 else {
            return "0%"
        }
        let rate = Double(summary.analyzedSwingCount) / Double(summary.totalSwingCount)
        return "\(Int((rate * 100).rounded()))%"
    }

    private var rankedErrors: [RankedError] {
        summary.repeatedErrors.enumerated().map { index, error in
            RankedError(rank: index + 1, error: error)
        }
    }
}

private struct RankedError: Identifiable {
    let rank: Int
    let error: ErrorCount

    var id: CoachingErrorType {
        error.id
    }
}

private struct RepeatedErrorRow: View {
    let rank: Int
    let error: ErrorCount
    let analyzedSwingCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Text("\(rank)")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(CoachTheme.courtBlue, in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(error.cue.text)
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(CoachTheme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("분석된 스윙 중 \(error.count)회")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CoachTheme.secondaryText)
                }

                Spacer(minLength: 8)

                StatusCapsule("\(error.count)회", tone: rank == 1 ? .warning : .neutral)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.18))
                    Capsule(style: .continuous)
                        .fill(rank == 1 ? CoachTheme.tennisTint : CoachTheme.courtBlue.opacity(0.72))
                        .frame(width: proxy.size.width * progressRatio)
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(CoachTheme.glassStroke, lineWidth: 1)
        }
    }

    private var progressRatio: CGFloat {
        guard analyzedSwingCount > 0 else {
            return 0
        }
        return min(1, CGFloat(error.count) / CGFloat(analyzedSwingCount))
    }
}
